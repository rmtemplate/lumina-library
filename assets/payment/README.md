# Payment Method Logos

No official Midtrans/brand logo image files are bundled here — this
session didn't fetch third-party trademarked brand assets (that needs the
real files from each brand's own press kit / Midtrans's own asset bundle,
not something to download unprompted). `PaymentLogo` (see
`lib/shared/widgets/payment/payment_logo.dart`) renders a clean, branded
code-drawn badge (correct brand color + initials/icon) as the default for
every method, and **automatically prefers a real asset file here if one
exists** — so adding the real logos later is just dropping files in with
the exact names below, no code changes needed.

Expected filenames (referenced by `PaymentLogo`):

| File | Method |
|---|---|
| `qris.png` | QRIS |
| `bca.png` | BCA Virtual Account |
| `bni.png` | BNI Virtual Account |
| `bri.png` | BRI Virtual Account |
| `permata.png` | Permata Virtual Account |
| `mandiri.png` | Mandiri Bill Payment |
| `gopay.png` | GoPay |
| `shopeepay.png` | ShopeePay |

Recommended: square or near-square PNGs with transparent background,
~256×256px.
