# Shopify CSV → Mobazha Field Mapping

## Shopify CSV Header (Standard Export)

```
Handle,Title,Body (HTML),Vendor,Type,Tags,Published,
Option1 Name,Option1 Value,Option2 Name,Option2 Value,Option3 Name,Option3 Value,
Variant SKU,Variant Grams,Variant Inventory Tracker,Variant Inventory Qty,Variant Inventory Policy,
Variant Fulfillment Service,Variant Price,Variant Compare At Price,Variant Requires Shipping,
Variant Taxable,Variant Barcode,Image Src,Image Position,Image Alt Text,
Gift Card,SEO Title,SEO Description,Google Shopping / Google Product Category,
Google Shopping / Gender,Google Shopping / Age Group,Google Shopping / MPN,
Google Shopping / AdWords Grouping,Google Shopping / AdWords Labels,
Google Shopping / Condition,Google Shopping / Custom Product,Google Shopping / Custom Label 0,
Google Shopping / Custom Label 1,Google Shopping / Custom Label 2,Google Shopping / Custom Label 3,
Google Shopping / Custom Label 4,Variant Image,Variant Weight Unit,Variant Tax Code,Cost per item,Status
```

## Key Mappings

| Shopify Field | Mobazha Field | Transform |
|---------------|---------------|-----------|
| `Handle` | — | Used for deduplication only |
| `Title` | `title` | Direct copy |
| `Body (HTML)` | `description` | Strip HTML tags |
| `Vendor` | — | Informational |
| `Type` | `categories[0]` | Map to Mobazha category |
| `Tags` | `tags[]` | Split by comma |
| `Variant Price` | `price` | Parse as decimal |
| `Variant SKU` | `variants[].sku` | Direct copy |
| `Variant Inventory Qty` | `quantity` | Parse as integer |
| `Image Src` | `images[]` | Download and re-upload |
| `Option1 Name` + `Option1 Value` | `variants[].options` | Map to Mobazha variant |
| `Variant Requires Shipping` | `shippingRequired` | `TRUE` → physical item |
| `Google Shopping / Condition` | `condition` | Map: `new`→`NEW`, `used`→`USED` |
| `Status` | — | Only import `active` products |

## Multi-Variant Products

Shopify CSV uses multiple rows per product. The first row has the title and main image; subsequent rows with the same Handle contain variant data.

Group rows by `Handle` to reconstruct the full product with all variants.
