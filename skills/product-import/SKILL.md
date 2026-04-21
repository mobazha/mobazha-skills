# Product Import

Import products from Shopify, Amazon, Etsy, and other e-commerce platforms into your Mobazha store.

## Overview

This skill helps you migrate or copy product listings from existing platforms into Mobazha. The process involves:

1. **Extract** — scrape or export product data from the source platform
2. **Transform** — convert to Mobazha's listing format
3. **Load** — create listings in your Mobazha store via the Admin API

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

### Step 2: Parse the CSV

Shopify CSV columns map to Mobazha fields as follows:

| Shopify Column | Mobazha Field | Notes |
|----------------|---------------|-------|
| Title | `title` | Product name |
| Body (HTML) | `description` | Strip HTML tags for clean text |
| Vendor | `categories` | Map to appropriate category |
| Type | `categories` | Additional categorization |
| Tags | `tags` | Comma-separated |
| Variant Price | `price` | Primary variant price |
| Variant SKU | `variants[].sku` | If multiple variants |
| Image Src | `images[]` | Download and re-upload URLs |
| Variant Inventory Qty | `quantity` | Stock count |

### Step 3: Create Listings

For each product row in the CSV, construct a Mobazha listing and create it via the store's Admin API:

```
POST /v1/listings
Content-Type: application/json
Cookie: <session-cookie>

{
  "title": "Product Name",
  "description": "Product description text",
  "price": 29.99,
  "priceCurrency": "USD",
  "quantity": 100,
  "categories": ["Category"],
  "tags": ["tag1", "tag2"],
  "images": [{"hash": "<image-hash-from-upload>"}],
  "condition": "NEW",
  "listingType": "FIXED_PRICE"
}
```

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

### Step 3: Transform and Load

Convert the scraped data to Mobazha listing format and POST to the Admin API (same as Shopify Method Step 3).

### Important Notes on Scraping

- Respect robots.txt and rate limits
- Amazon may block automated access; use appropriate delays between requests
- Product descriptions may need editing for your store context
- Verify pricing — don't blindly copy competitor prices
- Images: download and re-upload rather than hotlinking

## Method 3: CSV Bulk Import

For any platform that supports CSV export, prepare a CSV with these columns:

```csv
title,description,price,currency,quantity,category,tags,image_urls,condition
"Product 1","Description here",19.99,USD,50,"Electronics","gadget,tech","https://img1.jpg|https://img2.jpg",NEW
"Product 2","Another item",9.99,USD,100,"Clothing","fashion","https://img3.jpg",NEW
```

Then iterate rows and create listings via the Admin API.

## Working with the Admin API

### Authentication

Mobazha stores use session-based authentication. The user should provide:
- The store URL (e.g., `https://shop.example.com`)
- Admin username and password

Log in via `POST /v1/login` to obtain a session cookie, then include it in subsequent requests.

### Uploading Images

Before creating a listing, upload images:

```
POST /v1/media
Content-Type: application/json
Cookie: <session-cookie>

[{ "image": "<base64-encoded-image-data>", "filename": "product-photo.jpg" }]
```

The response returns image hashes to reference in the listing's `images` array.

See also: `references/shopify-csv-mapping.md` for detailed field mapping from Shopify CSV exports.

### Rate Considerations

When importing many products:
- Process one at a time to avoid overwhelming the store
- Wait for each listing creation to succeed before starting the next
- Upload images first, then reference them in the listing
- Report progress to the user (e.g., "Created 15/50 listings...")

## Credential Handling

- If the user provides store admin credentials, use them only for the import session
- Never store, log, or display API keys or passwords after use
- For Shopify/Etsy API access, the user should provide their own API keys

## Limitations

- Product reviews cannot be imported (they are store-specific)
- Shipping profiles need to be configured separately in Mobazha
- Payment options are set at the store level, not per-product
- Digital product files must be re-uploaded to Mobazha
