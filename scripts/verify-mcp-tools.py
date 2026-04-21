#!/usr/bin/env python3
"""
MCP Tool Verification — Layer 3 E2E Script

Connects to the Mobazha MCP SSE endpoint and validates:
1. SSE connection + session establishment
2. JSON-RPC tool discovery (tools/list)
3. Read-only tool calls with JSON structure assertions
4. Multi-user tenant isolation

The SSE MCP protocol works asynchronously:
  - Client opens SSE stream → receives endpoint URL
  - Client POSTs JSON-RPC messages → server returns 202
  - Server sends response back through SSE stream

Requires: pip install requests sseclient-py
"""

import json
import os
import queue
import sys
import threading
import uuid

import requests

try:
    import sseclient
except ImportError:
    print("ERROR: sseclient-py not installed. Run: pip install sseclient-py")
    sys.exit(1)

GATEWAY_URL = os.environ.get("GATEWAY_URL", "http://localhost:18080")
CASDOOR_URL = os.environ.get("CASDOOR_URL", "http://localhost:18000")
CASDOOR_CLIENT_ID = os.environ.get("CASDOOR_CLIENT_ID", "e2e-mobazha-client-id")
CASDOOR_CLIENT_SECRET = os.environ.get("CASDOOR_CLIENT_SECRET", "e2e-mobazha-client-secret")
PASSWORD = os.environ.get("E2E_TEST_PASSWORD", "123")

passed = 0
failed = 0
skipped = 0


def log_pass(name):
    global passed
    passed += 1
    print(f"  PASS  {name}")


def log_fail(name, reason):
    global failed
    failed += 1
    print(f"  FAIL  {name}: {reason}")


def log_skip(name, reason):
    global skipped
    skipped += 1
    print(f"  SKIP  {name}: {reason}")


def acquire_token(username):
    """Get Bearer token via OAuth password grant."""
    resp = requests.post(
        f"{CASDOOR_URL}/api/login/oauth/access_token",
        data={
            "grant_type": "password",
            "client_id": CASDOOR_CLIENT_ID,
            "client_secret": CASDOOR_CLIENT_SECRET,
            "username": username,
            "password": PASSWORD,
        },
        timeout=15,
    )
    resp.raise_for_status()
    data = resp.json()
    token = data.get("access_token", "")
    if not token:
        raise RuntimeError(f"Login failed for {username}: {data}")
    return token


class MCPSession:
    """Manages a full MCP SSE session with async response reading."""

    def __init__(self, token):
        self.token = token
        self.headers = {"Authorization": f"Bearer {token}"}
        self.message_url = None
        self.response_queue = queue.Queue()
        self._sse_resp = None
        self._reader_thread = None
        self._endpoint_ready = threading.Event()

    def connect(self, timeout=10):
        """Establish SSE connection and start reading events."""
        sse_url = f"{GATEWAY_URL}/platform/v1/mcp/sse"
        self._sse_resp = requests.get(
            sse_url, headers=self.headers, stream=True, timeout=timeout
        )
        self._sse_resp.raise_for_status()

        self._reader_thread = threading.Thread(
            target=self._read_events, daemon=True
        )
        self._reader_thread.start()

        if not self._endpoint_ready.wait(timeout=timeout):
            raise RuntimeError("Timeout waiting for endpoint event")

        return self.message_url

    def _read_events(self):
        """Background thread reading SSE events."""
        try:
            client = sseclient.SSEClient(self._sse_resp)
            for event in client.events():
                if event.event == "endpoint":
                    url = event.data
                    if url.startswith("/"):
                        url = GATEWAY_URL + url
                    self.message_url = url
                    self._endpoint_ready.set()
                elif event.event == "message":
                    try:
                        data = json.loads(event.data)
                        self.response_queue.put(data)
                    except json.JSONDecodeError:
                        pass
        except Exception:
            self._endpoint_ready.set()

    def send(self, method, params=None, timeout=15):
        """Send a JSON-RPC request and wait for the response via SSE."""
        if not self.message_url:
            raise RuntimeError("Not connected")

        request_id = str(uuid.uuid4())[:8]
        payload = {
            "jsonrpc": "2.0",
            "id": request_id,
            "method": method,
            "params": params or {},
        }
        resp = requests.post(
            self.message_url,
            headers={**self.headers, "Content-Type": "application/json"},
            json=payload,
            timeout=timeout,
        )
        if resp.status_code not in (200, 202):
            raise RuntimeError(
                f"POST returned {resp.status_code}: {resp.text[:200]}"
            )

        try:
            result = self.response_queue.get(timeout=timeout)
            return result.get("result", result)
        except queue.Empty:
            raise RuntimeError(f"Timeout waiting for response to {method}")

    def call_tool(self, tool_name, arguments=None, timeout=15):
        """Call an MCP tool and return the result."""
        return self.send(
            "tools/call",
            {"name": tool_name, "arguments": arguments or {}},
            timeout=timeout,
        )

    def close(self):
        """Close the SSE connection."""
        if self._sse_resp:
            self._sse_resp.close()


# ========== Test Functions ==========


def test_sse_connection(token):
    """Test 1: SSE connection and session establishment."""
    try:
        session = MCPSession(token)
        url = session.connect(timeout=10)
        session.close()
        if url and "sessionId" in url:
            log_pass("SSE connection + session ID")
            return True
        log_fail("SSE connection", f"unexpected endpoint: {url}")
        return False
    except Exception as e:
        log_fail("SSE connection", str(e))
        return False


def test_session_flow(session):
    """Test 2-4: Initialize, tool discovery, and read-only calls."""

    # 2. Initialize
    try:
        result = session.send("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {},
            "clientInfo": {"name": "verify-mcp-tools", "version": "0.1.0"},
        })
        if result and ("serverInfo" in result or "protocolVersion" in result):
            log_pass("Initialize")
        else:
            log_pass("Initialize (accepted)")
    except Exception as e:
        log_fail("Initialize", str(e))
        return False

    # Send initialized notification (no response expected)
    try:
        requests.post(
            session.message_url,
            headers={**session.headers, "Content-Type": "application/json"},
            json={"jsonrpc": "2.0", "method": "notifications/initialized"},
            timeout=5,
        )
    except Exception:
        pass

    # 3. Tool Discovery
    try:
        result = session.send("tools/list", {})
        tools = result.get("tools", [])
        names = {t["name"] for t in tools}

        required = {
            "listings_list_mine", "listings_create", "listings_get_template",
            "orders_get_sales", "orders_get_purchases",
            "profile_get", "chat_get_conversations",
            "exchange_rates_get", "wallet_get_receiving_accounts",
        }
        missing = required - names
        if missing:
            log_fail("Tool discovery", f"missing: {missing}")
        else:
            for tool in tools:
                if not tool.get("description"):
                    log_fail("Tool discovery", f"{tool['name']} empty description")
                    break
            else:
                log_pass(f"Tool discovery ({len(tools)} tools)")
    except Exception as e:
        log_fail("Tool discovery", str(e))

    # 4. Read-only tool calls
    readonly_tools = [
        "listings_list_mine",
        "profile_get",
        "exchange_rates_get",
        "settings_get_storefront",
        "orders_get_sales",
        "notifications_list",
    ]
    for tool_name in readonly_tools:
        try:
            result = session.call_tool(tool_name)
            is_error = result.get("isError", False)
            if is_error:
                text = ""
                content = result.get("content", [])
                if content:
                    text = content[0].get("text", "")[:200]
                log_fail(f"Tool call: {tool_name}", f"isError: {text}")
                continue

            content = result.get("content", [])
            if not content:
                log_fail(f"Tool call: {tool_name}", "empty content")
                continue

            text = content[0].get("text", "")
            try:
                json.loads(text)
                log_pass(f"Tool call: {tool_name}")
            except json.JSONDecodeError:
                if len(text) > 0:
                    log_pass(f"Tool call: {tool_name} (non-JSON, {len(text)} bytes)")
                else:
                    log_fail(f"Tool call: {tool_name}", "empty text")
        except Exception as e:
            log_fail(f"Tool call: {tool_name}", str(e))

    return True


def test_multi_user_isolation(token1, token2):
    """Test 5: Multi-user tenant isolation."""
    s1 = None
    s2 = None
    try:
        s1 = MCPSession(token1)
        s1.connect()
        s1.send("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {},
            "clientInfo": {"name": "verify-iso-1", "version": "0.1.0"},
        })
        requests.post(
            s1.message_url,
            headers={**s1.headers, "Content-Type": "application/json"},
            json={"jsonrpc": "2.0", "method": "notifications/initialized"},
            timeout=5,
        )

        s2 = MCPSession(token2)
        s2.connect()
        s2.send("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {},
            "clientInfo": {"name": "verify-iso-2", "version": "0.1.0"},
        })
        requests.post(
            s2.message_url,
            headers={**s2.headers, "Content-Type": "application/json"},
            json={"jsonrpc": "2.0", "method": "notifications/initialized"},
            timeout=5,
        )

        p1 = s1.call_tool("profile_get")
        p2 = s2.call_tool("profile_get")

        text1 = p1.get("content", [{}])[0].get("text", "")
        text2 = p2.get("content", [{}])[0].get("text", "")

        data1 = json.loads(text1) if text1 else {}
        data2 = json.loads(text2) if text2 else {}

        peer1 = data1.get("peerID", data1.get("data", {}).get("peerID", ""))
        peer2 = data2.get("peerID", data2.get("data", {}).get("peerID", ""))

        if not peer1 or not peer2:
            log_fail("Multi-user isolation",
                     f"missing peerIDs: user1={peer1!r} user2={peer2!r}")
            return False

        if peer1 == peer2:
            log_fail("Multi-user isolation",
                     f"same peerID {peer1} for different users")
            return False

        log_pass("Multi-user isolation")
        return True
    except Exception as e:
        log_fail("Multi-user isolation", str(e))
        return False
    finally:
        if s1:
            s1.close()
        if s2:
            s2.close()


def main():
    print("=" * 60)
    print("MCP Tool Verification")
    print(f"Gateway: {GATEWAY_URL}")
    print("=" * 60)

    print("\n--- Acquiring tokens ---")
    try:
        token1 = acquire_token("testuser1")
        print(f"  testuser1: token acquired ({len(token1)} chars)")
    except Exception as e:
        print(f"FATAL: Cannot acquire token for testuser1: {e}")
        sys.exit(1)

    try:
        token2 = acquire_token("testuser2")
        print(f"  testuser2: token acquired ({len(token2)} chars)")
    except Exception as e:
        print(f"FATAL: Cannot acquire token for testuser2: {e}")
        sys.exit(1)

    print("\n--- 1. SSE Connection ---")
    test_sse_connection(token1)

    print("\n--- 2-4. MCP Session Flow ---")
    session = MCPSession(token1)
    try:
        session.connect()
        test_session_flow(session)
    except Exception as e:
        log_fail("MCP Session", str(e))
    finally:
        session.close()

    print("\n--- 5. Multi-user Isolation ---")
    test_multi_user_isolation(token1, token2)

    print("\n" + "=" * 60)
    total = passed + failed + skipped
    print(f"Results: {passed} passed, {failed} failed, {skipped} skipped"
          f" (total: {total})")
    print("=" * 60)

    sys.exit(1 if failed > 0 else 0)


if __name__ == "__main__":
    main()
