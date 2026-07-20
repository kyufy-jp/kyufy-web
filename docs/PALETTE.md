# PALETTE.md — kyufy Color Palette

> Source: Refactoring UI, Palette 19 ("Enterprise": Indigo + Orange Vivid / Cool Grey).
> Chosen for kyufy because: **Indigo** reads as public-money trust without copying デジタル庁 blue or Zaim green; **Orange (Vivid)** carries the positive "money you can receive" energy for CTAs/accents; the supporting colors map 1:1 to kyufy's three verdicts — 該当 = Green, 非該当 = Red, 要確認 = Yellow.
>
> Shade convention (Refactoring UI): 1 = darkest … 10 = lightest.
> Tailwind mapping used in kyufy-web: shade 1→900, 2→800, 3→700, 4→600, 5→500, 6→400, 7→300, 8→200, 9→100, 10→50.

---

## Primary: Indigo — brand / trust (`primary`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#19216C` | `hsl(234, 62%, 26%)` |
| 2 | 800 | `#2D3A8C` | `hsl(232, 51%, 36%)` |
| 3 | 700 | `#35469C` | `hsl(230, 49%, 41%)` |
| 4 | 600 | `#4055A8` | `hsl(228, 45%, 45%)` |
| 5 | 500 | `#4C63B6` | `hsl(227, 42%, 51%)` |
| 6 | 400 | `#647ACB` | `hsl(227, 50%, 59%)` |
| 7 | 300 | `#7B93DB` | `hsl(225, 57%, 67%)` |
| 8 | 200 | `#98AEEB` | `hsl(224, 67%, 76%)` |
| 9 | 100 | `#BED0F7` | `hsl(221, 78%, 86%)` |
| 10 | 50 | `#E0E8F9` | `hsl(221, 68%, 93%)` |

Use: main CTA（判定する）= 500, hover = 400, active = 700. Links = 600. Assistant chat bubble bg = 50. 要綱 quote left border = 300.

## Primary: Orange (Vivid) — accent / warmth (`accent`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#841003` | `hsl(6, 96%, 26%)` |
| 2 | 800 | `#AD1D07` | `hsl(8, 92%, 35%)` |
| 3 | 700 | `#C52707` | `hsl(10, 93%, 40%)` |
| 4 | 600 | `#DE3A11` | `hsl(12, 86%, 47%)` |
| 5 | 500 | `#F35627` | `hsl(14, 89%, 55%)` |
| 6 | 400 | `#F9703E` | `hsl(16, 94%, 61%)` |
| 7 | 300 | `#FF9466` | `hsl(18, 100%, 70%)` |
| 8 | 200 | `#FFB088` | `hsl(20, 100%, 77%)` |
| 9 | 100 | `#FFD0B5` | `hsl(22, 100%, 85%)` |
| 10 | 50 | `#FFE8D9` | `hsl(24, 100%, 93%)` |

Use: sparingly — the single most important CTA on screen, or the 該当 count highlight in a summary line. Never on large surfaces.

## Neutrals: Cool Grey — text / backgrounds / borders (`neutral`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#1F2933` | `hsl(210, 24%, 16%)` |
| 2 | 800 | `#323F4B` | `hsl(209, 20%, 25%)` |
| 3 | 700 | `#3E4C59` | `hsl(209, 18%, 30%)` |
| 4 | 600 | `#52606D` | `hsl(209, 14%, 37%)` |
| 5 | 500 | `#616E7C` | `hsl(211, 12%, 43%)` |
| 6 | 400 | `#7B8794` | `hsl(211, 10%, 53%)` |
| 7 | 300 | `#9AA5B1` | `hsl(211, 13%, 65%)` |
| 8 | 200 | `#CBD2D9` | `hsl(210, 16%, 82%)` |
| 9 | 100 | `#E4E7EB` | `hsl(214, 15%, 91%)` |
| 10 | 50 | `#F5F7FA` | `hsl(216, 33%, 97%)` |

Use: 60–70% of the UI. Page bg = 50, card bg = white, headings = 900, body text = 700, secondary text = 500, borders = 100/200. 要綱 quote block bg = 50.

## Supporting: Green (Vivid) — 該当 / success (`success`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#014807` | `hsl(125, 97%, 14%)` |
| 2 | 800 | `#07600E` | `hsl(125, 86%, 20%)` |
| 3 | 700 | `#0E7817` | `hsl(125, 79%, 26%)` |
| 4 | 600 | `#0F8613` | `hsl(122, 80%, 29%)` |
| 5 | 500 | `#18981D` | `hsl(122, 73%, 35%)` |
| 6 | 400 | `#31B237` | `hsl(123, 57%, 45%)` |
| 7 | 300 | `#51CA58` | `hsl(123, 53%, 55%)` |
| 8 | 200 | `#91E697` | `hsl(124, 63%, 74%)` |
| 9 | 100 | `#C1F2C7` | `hsl(127, 65%, 85%)` |
| 10 | 50 | `#E3F9E5` | `hsl(125, 65%, 93%)` |

Use: 該当 badge = 700 text on 50 bg.

## Supporting: Red (Vivid) — 非該当 / danger (`danger`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#610316` | `hsl(348, 94%, 20%)` |
| 2 | 800 | `#8A041A` | `hsl(350, 94%, 28%)` |
| 3 | 700 | `#AB091E` | `hsl(352, 90%, 35%)` |
| 4 | 600 | `#CF1124` | `hsl(354, 85%, 44%)` |
| 5 | 500 | `#E12D39` | `hsl(356, 75%, 53%)` |
| 6 | 400 | `#EF4E4E` | `hsl(360, 83%, 62%)` |
| 7 | 300 | `#F86A6A` | `hsl(360, 91%, 69%)` |
| 8 | 200 | `#FF9B9B` | `hsl(360, 100%, 80%)` |
| 9 | 100 | `#FFBDBD` | `hsl(360, 100%, 87%)` |
| 10 | 50 | `#FFE3E3` | `hsl(360, 100%, 95%)` |

Use: 非該当 badge = 600 text on 50 bg. Error states.

## Supporting: Yellow (Vivid) — 要確認 / warning (`warning`)
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#8D2B0B` | `hsl(15, 86%, 30%)` |
| 2 | 800 | `#B44D12` | `hsl(22, 82%, 39%)` |
| 3 | 700 | `#CB6E17` | `hsl(29, 80%, 44%)` |
| 4 | 600 | `#DE911D` | `hsl(36, 77%, 49%)` |
| 5 | 500 | `#F0B429` | `hsl(42, 87%, 55%)` |
| 6 | 400 | `#F7C948` | `hsl(44, 92%, 63%)` |
| 7 | 300 | `#FADB5F` | `hsl(48, 94%, 68%)` |
| 8 | 200 | `#FCE588` | `hsl(48, 95%, 76%)` |
| 9 | 100 | `#FFF3C4` | `hsl(48, 100%, 88%)` |
| 10 | 50 | `#FFFBEA` | `hsl(49, 100%, 96%)` |

Use: 要確認 badge = 600 text on 50 bg. Warnings, disclaimer emphasis.

## Supporting: Magenta (Vivid) — reserved (`magenta`)
Part of Palette 19; **not used in kyufy MVP**. Reserved for future needs (e.g. marketing highlights). Do not introduce into product UI without a reason.
| # | Tailwind | Hex | HSL |
|---|----------|-----|-----|
| 1 | 900 | `#6E0560` | `hsl(308, 91%, 23%)` |
| 2 | 800 | `#960888` | `hsl(306, 90%, 31%)` |
| 3 | 700 | `#B30BA3` | `hsl(306, 88%, 37%)` |
| 4 | 600 | `#CB10B8` | `hsl(306, 85%, 43%)` |
| 5 | 500 | `#E019D0` | `hsl(305, 80%, 49%)` |
| 6 | 400 | `#ED47ED` | `hsl(300, 82%, 60%)` |
| 7 | 300 | `#F368FC` | `hsl(296, 96%, 70%)` |
| 8 | 200 | `#F48FFF` | `hsl(294, 100%, 78%)` |
| 9 | 100 | `#F8C4FE` | `hsl(294, 97%, 88%)` |
| 10 | 50 | `#FDEBFF` | `hsl(294, 100%, 96%)` |

---

## Tailwind config (copy-paste)
```js
// tailwind.config.js — theme.extend.colors
colors: {
  primary: {   // Indigo
    50:'#E0E8F9',100:'#BED0F7',200:'#98AEEB',300:'#7B93DB',400:'#647ACB',
    500:'#4C63B6',600:'#4055A8',700:'#35469C',800:'#2D3A8C',900:'#19216C',
  },
  accent: {    // Orange (Vivid)
    50:'#FFE8D9',100:'#FFD0B5',200:'#FFB088',300:'#FF9466',400:'#F9703E',
    500:'#F35627',600:'#DE3A11',700:'#C52707',800:'#AD1D07',900:'#841003',
  },
  neutral: {   // Cool Grey
    50:'#F5F7FA',100:'#E4E7EB',200:'#CBD2D9',300:'#9AA5B1',400:'#7B8794',
    500:'#616E7C',600:'#52606D',700:'#3E4C59',800:'#323F4B',900:'#1F2933',
  },
  success: {   // Green (Vivid) — 該当
    50:'#E3F9E5',100:'#C1F2C7',200:'#91E697',300:'#51CA58',400:'#31B237',
    500:'#18981D',600:'#0F8613',700:'#0E7817',800:'#07600E',900:'#014807',
  },
  danger: {    // Red (Vivid) — 非該当
    50:'#FFE3E3',100:'#FFBDBD',200:'#FF9B9B',300:'#F86A6A',400:'#EF4E4E',
    500:'#E12D39',600:'#CF1124',700:'#AB091E',800:'#8A041A',900:'#610316',
  },
  warning: {   // Yellow (Vivid) — 要確認
    50:'#FFFBEA',100:'#FFF3C4',200:'#FCE588',300:'#FADB5F',400:'#F7C948',
    500:'#F0B429',600:'#DE911D',700:'#CB6E17',800:'#B44D12',900:'#8D2B0B',
  },
  magenta: {   // Magenta (Vivid) — reserved, unused in MVP
    50:'#FDEBFF',100:'#F8C4FE',200:'#F48FFF',300:'#F368FC',400:'#ED47ED',
    500:'#E019D0',600:'#CB10B8',700:'#B30BA3',800:'#960888',900:'#6E0560',
  },
}
```

## Quick reference — kyufy UI roles
| Element | Class / value |
|---|---|
| Page background | `neutral-50` `#F5F7FA` |
| Card background | white |
| Heading text | `neutral-900` `#1F2933` |
| Body text | `neutral-700` `#3E4C59` |
| Secondary text | `neutral-500` `#616E7C` |
| Borders | `neutral-100/200` |
| Main CTA（判定する） | bg `primary-500`, hover `primary-400`, active `primary-700` |
| Links | `primary-600` |
| Accent CTA / 該当 count highlight | `accent-500` `#F35627`（少量のみ） |
| 該当 badge | text `success-700` on `success-50` |
| 非該当 badge | text `danger-600` on `danger-50` |
| 要確認 badge | text `warning-600` on `warning-50` |
| 要綱 quote block | bg `neutral-50`, left border `primary-300`, text `neutral-700` |
| Assistant chat bubble | bg `primary-50` |

Contrast: the text/bg pairs above meet WCAG AA. Keep AA when adjusting shades.
