# Product Import

Import products from Shopify, Amazon, Etsy, and other e-commerce platforms into your Mobazha store.

## Overview

This skill helps you migrate or copy product listings from existing platforms into Mobazha. Two approaches are available:

- **Bulk Import (recommended)** — package products as a ZIP with JSON + images and upload in one call
- **Individual Create** — create listings one at a time via the Admin API

## Bulk Import via MCP Tool

If the store is connected via MCP, use the `listings_import_json` tool for the fastest bulk import:

```json
{
  "import_json": "{\"listings\":[...], \"shippingProfiles\":[...]}",
  "images_base64": "{\"photo1.jpg\":\"<base64>\",\"photo2.jpg\":\"<base64>\"}"
}
```

The tool builds a ZIP archive internally and uploads it to `POST /v1/listings/import/json`.

### import_json Schema

```json
{
  "listings": [
    {
      "slug": "unique-product-slug",
      "title": "Product Name",
      "contractType": "PHYSICAL_GOOD",
      "price": "29.99",
      "pricingCurrency": "USD",
      "description": "Product description",
      "tags": ["tag1", "tag2"],
      "condition": "NEW",
      "nsfw": false,
      "images": ["photo1.jpg", "photo2.jpg"],
      "quantity": 100,
      "shippingProfileId": "Standard Shipping"
    }
  ],
  "shippingProfiles": [
    {
      "key": "Standard Shipping",
      "name": "Standard Shipping",
      "isDefault": true,
      "locationGroups": [
        {
          "name": "Worldwide",
          "locations": [{ "country": "ALL" }],
          "shippingOptions": [
            { "name": "Standard", "type": "FIXED_PRICE", "price": "5.00" }
          ]
        }
      ]
    }
  ],
  "profile": {
    "name": "Store Name",
    "about": "Store description"
  }
}
```

### Contract Types

| Type | Notes |
|------|-------|
| `PHYSICAL_GOOD` | Requires `shippingProfileId` matching a profile key/name |
| `DIGITAL_GOOD` | No shipping needed |
| `SERVICE` | No shipping needed |
| `CRYPTOCURRENCY` | Token/coin listings |

### Image Handling

Images referenced in `listings[].images` must be provided as base64-encoded data in the `images_base64` parameter. The filenames must match exactly.

To prepare images:
1. Download product images from the source platform
2. Base64-encode each image file
3. Build the `images_base64` JSON map: `{"filename.jpg": "<base64-data>"}`

## Bulk Import via Direct API

For non-MCP contexts (e.g., shell scripts), build a ZIP file manually:

### ZIP Structure

```
my-import/
├── listings.json          # Required: product data + shipping profiles
├── profile.json           # Optional: store profile data
├── images/                # Product images referenced in listings.json
│   ├── photo1.jpg
│   ├── photo2.png
│   └── ...
└── videos/                # Optional: intro videos
    └── demo.mp4
```

### Upload

```bash
curl -X POST "https://your-store.example.com/v1/listings/import/json" \
  -H "Authorization: Bearer <token>" \
  -F "file=@my-import.zip"
```

### Response

```json
{
  "data": {
    "total": 10,
    "created": 8,
    "updated": 2,
    "failed": 0,
    "createdItems": [{ "slug": "product-1", "title": "Product 1" }],
    "updatedItems": [{ "slug": "product-2", "title": "Product 2" }],
    "errors": []
  }
}
```

## Supported Sources

| Source | Method | Notes |
|--------|--------|-------|
| Shopify | CSV export or API | Best option: export from Shopify admin |
| Amazon | Web scraping | Product detail pages |
| Etsy | CSV export or API | Best option: export from Etsy Shop Manager |
| WooCommerce | CSV/JSON export | Export from WooCommerce admin |
| Generic CSV | Manual | Any CSV with title, description, price, images |

## Method 1: Shopify Import (CSV)

### Step 1: Export from Shopify

1. In Shopify Admin, go to **Products → All Products**
2. Click **Export** → select **All products** → **CSV for Excel/Numbers**
3. Download the CSV file

### Step 2: Transform to Mobazha Format

Shopify CSV columns map to Mobazha fields:

| Shopify Column | Mobazha Field | Notes |
|----------------|---------------|-------|
| Title | `title` | Product name |
| Body (HTML) | `description` | Strip HTML tags for clean text |
| Vendor | `tags` | Map to appropriate tags |
| Type | `tags` | Additional categorization |
| Tags | `tags` | Comma-separated |
| Variant Price | `price` | Primary variant price |
| Variant SKU | `variants[].productID` | SKU identifier |
| Image Src | `images[]` | Download and include in ZIP |
| Variant Inventory Qty | `quantity` | Stock count |

### Step 3: Build and Upload

1. Parse CSV rows, grouping variants by product handle
2. Download all product images
3. Build the `listings.json` with shipping profiles
4. Package into a ZIP and upload via `listings_import_json` MCP tool or direct API

## Method 2: Amazon Product Scraping

### Step 1: Identify Products

Collect Amazon product URLs or ASINs to import. Example:

```
https://www.amazon.com/dp/B0XXXXXXXXX
```

### Step 2: Extract Product Data

For each product URL, extract:

- **Title**: product name
- **Description**: bullet points + product description
- **Price**: current selling price
- **Images**: all product images (high-resolution)
- **Variants**: color, size, or other options
- **Category**: Amazon browse node category

#### Scraping Approach

Use the product page to extract structured data:

```python
import requests
from bs4 import BeautifulSoup

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
}

def scrape_amazon_product(url):
    resp = requests.get(url, headers=headers)
    soup = BeautifulSoup(resp.text, "html.parser")

    title = soup.find("span", id="productTitle")
    price = soup.find("span", class_="a-price-whole")
    images = soup.find_all("img", class_="a-dynamic-image")
    bullets = soup.find("div", id="feature-bullets")

    return {
        "title": title.get_text(strip=True) if title else "",
        "price": float(price.get_text(strip=True).replace(",", "")) if price else 0,
        "images": [img.get("src", "").replace("_AC_US40_", "_AC_SL1500_") for img in images],
        "description": bullets.get_text(strip=True) if bullets else "",
    }
```

### Step 3: Transform and Upload

Convert extracted data to the bulk import JSON format and use the `listings_import_json` MCP tool.

### Important Notes on Scraping

- Respect robots.txt and rate limits
- Amazon may block automated access; use appropriate delays between requests
- Product descriptions may need editing for your store context
- Verify pricing — don't blindly copy competitor prices
- Download images locally rather than hotlinking

## Method 3: Individual Listing Create

For small imports (< 10 products), create listings one at a time via the `listings_create` MCP tool:

```json
{
  "listing_json": "{\"slug\":\"my-product\",\"metadata\":{\"contractType\":\"DIGITAL_GOOD\",...},\"item\":{\"title\":\"...\",\"price\":\"9.99\",...}}"
}
```

Or via the Admin API:

```
POST /v1/listings
Content-Type: application/json
Authorization: Bearer <token>
```

Images must be uploaded first via `POST /v1/media` to obtain content hashes.

## Authentication

### MCP Connection

If the store is connected via MCP (recommended), authentication is handled automatically through the MCP session token.

### Direct API Access

For direct API calls, authenticate via OAuth to obtain a Bearer token, then include it in the `Authorization` header.

## Rate Considerations

- Bulk import handles rate management internally — one ZIP upload imports all products
- For individual creates, process one at a time and wait for each to succeed
- Report progress to the user (e.g., "Created 15/50 listings...")
- Large ZIP files (100+ products with images) may take 30-60 seconds to process

## Credential Handling

- Never store, log, or display API keys or passwords after use
- For Shopify/Etsy API access, the user should provide their own API keys
- MCP tokens are session-scoped and managed by the platform

## Limitations

- Product reviews cannot be imported (they are store-specific)
- Physical goods require shipping profiles — include them in the import JSON
- Payment options are set at the store level, not per-product
- Digital product files must be re-uploaded to Mobazha
- Maximum ZIP size: 300 MB (configurable)
- Maximum video size per listing: 15 MB
