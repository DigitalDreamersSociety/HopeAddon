# Reputation Tab Implementation Status

**Document Version:** 1.0
**Created:** 2026-01-27
**Status:** Review in Progress

---

## Implementation Summary

### Completed ✓

| Feature | Status | Location |
|---------|--------|----------|
| Bar centering (80% width) | ✓ Done | Journal.lua:4392-4398 |
| Multi-icon containers (up to 4) | ✓ Done | Components.lua:2610-2643 |
| CLASS_SPEC_LOOT_HOTLIST as primary source | ✓ Done | Journal.lua:4459-4483 |
| Armory fallback (secondary) | ✓ Done | Journal.lua:4485-4518 |
| Generic rewards (tertiary, conditional) | ✓ Done | Journal.lua:4520-4539 |
| Deduplication across sources | ✓ Done | Journal.lua:4447-4457 |
| Icon pre-loading (cache warmup) | ✓ Done | ArmoryBisData.lua + Core.lua |
| Enhanced tooltips | ✓ Done | Components.lua:2917-2955 |
| Legacy container compatibility | ✓ Done | Components.lua:2770-2832 |
| All 9 classes, 27 specs covered | ✓ Done | Constants.lua:4620+ |

### Positioning Details

**Current Layout:**
```
                    Standing Labels (12px height)
                    ↓ positioned at: segBg TOP + (ICON_SIZE + ICON_SPACING + 2) = +26px

              [Icon] [Icon] [Icon] [Icon]   ← Multi-icon container
                    ↓ positioned at: divider TOP + 2px

    +-+-----+-------+----------+-------------+------+-+
    |N|  F  |   H   |    R     |      R      |  E   | |  ← Bar segments
    +-+-----+-------+----------+-------------+------+-+
              ↑       ↑          ↑            ↑
           Dividers (positioned between segments)
```

**Key Measurements:**
- Bar width: 80% of content width (contentWidth * 0.80)
- Left offset: (contentWidth - barWidth) / 2 (centers bar)
- Icon size: 20px
- Icon gap: 4px (between multiple icons)
- Max icons per standing: 4
- Label height: 12px
- Bar height: 18px
- Total container height: 58px

---

## Potential Issues to Verify

### 1. Frame Level / Z-Order
**Concern:** Icon containers created AFTER bar segments may render behind them.
**Current:** No explicit SetFrameLevel() calls found.
**Risk:** Low - containers are child frames of the main container.

### 2. Icon Container Initial Position
**Concern:** Containers are initially positioned at `segBg TOP + 2` but SetItemIcons repositions to dividers.
**Code Reference:**
- Initial: Components.lua:2615 `SetPoint("BOTTOM", segBg, "TOP", 0, 2)`
- Repositioned: Components.lua:2862-2872 moves to divider position

**Status:** Should be OK - SetItemIcons always repositions before showing.

### 3. Standing Labels vs Icons Overlap
**Concern:** Labels positioned at 26px above bar, icons at 2px above bar.
**Math:** Icons (20px) + gap would reach 22px. Labels start at 26px.
**Gap:** 4px clearance between icon top and label bottom.
**Status:** Should be OK - 4px gap is intentional (ICON_SPACING constant).

---

## Testing Checklist

### Visual Verification
- [ ] Bar is centered horizontally in faction card
- [ ] Icons appear above the correct dividers (not segment centers)
- [ ] Standing labels appear above icons with small gap
- [ ] Multiple icons at same standing are side-by-side
- [ ] BiS items have brighter gold border
- [ ] Unobtainable items are desaturated

### Data Verification
- [ ] Only spec-appropriate items shown (not all classes)
- [ ] Generic rewards (keys, tabards) only shown when no spec items at that standing
- [ ] Item tooltips show correct item info
- [ ] "BiS for your spec!" appears for Journey/Armory items
- [ ] "Requires: [Standing]" shows correct standing name

### Class/Spec Tests
- [ ] Elemental Shaman: Continuum Blade (KoT Revered), Shapeshifter's Signet (LC Exalted)
- [ ] Enhancement Shaman: Haramad's Bargain (Consortium Exalted)
- [ ] Resto Shaman: Gavel of Pure Light (Sha'tar Exalted), Lower City Prayerbook (LC Revered)
- [ ] Warrior DPS: Haramad's Bargain (Consortium), Marksman's Bow (Honor Hold)
- [ ] Holy Paladin: Gavel of Pure Light (Sha'tar), Lower City Prayerbook (LC)

---

## Code Locations Quick Reference

| Function | File | Line |
|----------|------|------|
| PopulateReputationItemIcons | Journal.lua | 4440 |
| CreateSegmentedReputationBar | Components.lua | 2507 |
| SetItemIcons | Components.lua | 2762 |
| SetProgress | Components.lua | 2677 |
| SetStandingHighlight | Components.lua | 2733 |
| WarmupReputationItemCache | ArmoryBisData.lua | 2913 |
| CLASS_SPEC_LOOT_HOTLIST | Constants.lua | 4620 |

---

## Conclusion

All major features appear to be implemented. The remaining work is primarily:
1. **In-game testing** to verify visual alignment
2. **User feedback** on any remaining misalignment issues

If icons still appear misaligned after `/reload`, the issue may be:
- Divider positions not matching expected locations
- Parent frame anchor calculations affecting child positions
- Need explicit frame level adjustments

**Recommended Next Step:** Test in-game with `/reload` and report specific visual issues (screenshots helpful).
