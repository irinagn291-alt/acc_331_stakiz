# Checklead

Checklead is an offline household rail for people who run chores by pet. Scan a collar tag, then snap each routine disc into that animal's slot. When every active disc is seated, the day clips shut.

## Architecture

The day is a jaunt-rail fold: Blank, Open, Snapping, or Clipped. Slots are the active routines for a daykey, grouped by pet. A known tag writes TagMark and folds Open into Snapping. A matching snap writes SeatMark. A wrong slot writes SkewMark. A drag before any tag writes DriftMark. A full rail writes ClipMark. Peel removes the last seat and reopens Snapping. Scan and drag are refused while Clipped. The fold is a pure reducer, so the rail cannot show a seat the ledger does not hold. One JauntLedger file is the projection of that state.

## Scan, then snap

Home keeps the rail and the disc dock on screen. The simulator seed already tags Mira and seats Feed, so the first move is snapping Walk. UIKit dynamics track the drag and snap the disc onto the slot. Peel undoes the last seat. The streak counts consecutive clipped days backward from today.

## Art

Brutalist xerox zine, typographic cutouts. Each asset used this prompt, plus the subject line in SPEC section 13:

Brutalist xerox zine cutout illustration with high-contrast halftone grain, photocopied ink stamp textures, bold typographic registration marks, and crisp die-cut silhouettes with transparent PNG alpha around the subject and solid opaque centers.

- chl_Onboarding1: a collar tag and dispatch ticket, the product in one glance
- chl_Onboarding2: a hand dropping a chore token onto a rail slot
- chl_Onboarding3: a stamp pressing a stack of clipped tickets
- chl_EmptyHome: a closed wooden crate and folded cloth
- chl_TwistHero: a collar ring locked onto a paper disc
- chl_EmptyHouseholdCutout: metal collar tag, key ring, and clipped ticket
- chl_ClippedSealStamp: rubber stamp reading CLIPPED

## How this differs

This is not a swipe queue, a mood companion, or a vet storefront. The persisted verb is seating a disc on a timeline after a collar scan.

## Build

```bash
cd apps/Checklead
xcodegen generate
xcodebuild -scheme Checklead -destination 'generic/platform=iOS' build
```

Deployment target iOS 17. No third-party packages.
