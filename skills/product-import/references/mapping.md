# Universal Field Mapping: External Platforms → Mobazha

## Mobazha Import JSON Fields (Target)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slug` | string | No | Unique URL slug; auto-generated from title if omitted |
| `title` | string | **Yes** | Product name |
| `contractType` | enum | **Yes** | `PHYSICAL_GOOD`, `DIGITAL_GOOD`, `SERVICE`, `CRYPTOCURRENCY` |
| `price` | string | **Yes** | Decimal price (e.g., `"29.99"`) |
| `pricingCurrency` | string | **Yes** | ISO 4217 currency code (e.g., `USD`, `EUR`) |
| `description` | string | No | Plain text or Markdown product description |
| `tags` | string[] | No | Categorization tags |
| `condition` | enum | No | `NEW`, `USED`, `REFURBISHED` (default: `NEW`) |
| `nsfw` | bool | No | Adult content flag (default: `false`) |
| `images` | string[] | No | Filenames matching entries in the ZIP `images/` dir |
| `quantity` | int | No | Stock quantity (default: unlimited) |
| `shippingProfileId` | string | Conditional | Required for `PHYSICAL_GOOD`; references `shippingProfiles[].key` |
| `variants` | object[] | No | Color, size, and other variant options |
| `variants[].name` | string | Yes | Option name (e.g., "Color") |
| `variants[].options` | string[] | Yes | Option values (e.g., ["Red", "Blue"]) |

## Cross-Platform Mapping Table

| Concept | Shopify (CSV) | Shopify (API) | Amazon | Etsy | WooCommerce | Mobazha |
|---------|--------------|---------------|--------|------|-------------|---------|
| Name | `Title` | `product.title` | `#productTitle` | `title` | `name` | `title` |
| Description | `Body (HTML)` | `product.body_html` | bullets + `#productDescription` | `description` | `description` | `description` |
| Price | `Variant Price` | `variants[].price` | `.a-price-whole` | `price` | `regular_price` | `price` |
| Currency | — (store default) | `presentment_prices` | — (page locale) | `currency_code` | `currency` | `pricingCurrency` |
| Images | `Image Src` | `images[].src` | `.a-dynamic-image` | `images[].url_570xN` | `images[].src` | `images[]` |
| SKU | `Variant SKU` | `variants[].sku` | ASIN | `sku` | `sku` | `variants[].sku` |
| Stock | `Variant Inventory Qty` | `variants[].inventory_quantity` | — | `quantity` | `stock_quantity` | `quantity` |
| Category | `Type` | `product_type` | breadcrumbs | `taxonomy_id` | `categories[]` | `tags[]` |
| Tags | `Tags` | `tags` | — | `tags` | `tags[]` | `tags[]` |
| Variants | `Option1/2/3` | `options[] + variants[]` | `#twister` | `variations[]` | `attributes[]` | `variants[]` |
| Weight | `Variant Grams` | `variants[].grams` | — | `item_weight` | `weight` | — |
| Condition | `Google Shopping / Condition` | — | — | — | `condition` | `condition` |
| Shipping | `Variant Requires Shipping` | `requires_shipping` | — (always physical) | `shipping_template_id` | `shipping_required` | `shippingProfileId` |
| Status | `Status` | `status` | — | `state` | `status` | — (only import active) |

## Transform Rules

### Description Cleaning

All sources may contain HTML. Clean before import:

1. Strip HTML tags (keep line breaks as `\n`)
2. Decode HTML entities (`&amp;` → `&`)
3. Remove excessive whitespace
4. Truncate to reasonable length (Mobazha allows up to 50,000 characters)

### Price Handling

1. Parse price as decimal number
2. Remove currency symbols and formatting (`,`, spaces)
3. Store as string with 2 decimal places: `"29.99"`
4. Set `pricingCurrency` to the appropriate ISO 4217 code

### Image Processing

1. Download all image URLs to local files
2. Use high-resolution versions where available
3. Supported formats: JPEG, PNG, WebP, GIF
4. Name files consistently: `product-slug-1.jpg`, `product-slug-2.jpg`
5. Reference filenames in `listings[].images` array
6. Provide files in the ZIP `images/` directory (or via `images_base64` for MCP)

### Variant Mapping

Different platforms represent variants differently:

| Platform | Structure | Mobazha Equivalent |
|----------|-----------|--------------------|
| Shopify | `Option1 Name`/`Value` columns per row | `variants[].name` + `variants[].options` |
| Amazon | Dropdown selectors in `#twister` | `variants[].name` + `variants[].options` |
| Etsy | `variations[]` with `property_id` | `variants[].name` + `variants[].options` |
| WooCommerce | `attributes[]` with `options` | `variants[].name` + `variants[].options` |

### Contract Type Detection

| Source Signal | Mobazha contractType |
|---------------|---------------------|
| Requires shipping / has weight | `PHYSICAL_GOOD` |
| Digital download / no shipping | `DIGITAL_GOOD` |
| Service / booking / appointment | `SERVICE` |
| Token / coin / crypto asset | `CRYPTOCURRENCY` |

## Shipping Profile Defaults

For `PHYSICAL_GOOD` listings, include at least one shipping profile:

```json
{
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
  ]
}
```

Set each physical listing's `shippingProfileId` to `"Standard Shipping"` (matching the profile `key`).
