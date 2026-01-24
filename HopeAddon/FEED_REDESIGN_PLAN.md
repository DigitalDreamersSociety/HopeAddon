# Activity Feed Redesign Plan

## Problem Statement

The current Activity Feed system conflates two distinct social features:
1. **STATUS** - RP status changes (IC/OOC/LF_RP) - automatic, tied to character identity
2. **RUMOR** - Manual posts - currently shows player name, but should support anonymous option

Users need clearer distinction between:
- **"In Character" posts** - Speaking as their character, with full identity visible
- **"Tavern Rumors"** - Anonymous gossip that spreads without attribution

Additionally, the current UI doesn't clearly communicate what each post type means.

---

## Proposed Solution: Two Distinct Post Types

### 1. IC Post (In Character)
- **Purpose**: Speaking as your character to the community
- **Attribution**: Full name + title + class icon visible
- **Visual**: Green/fel border, character portrait style
- **Format**: `[Thrall <Hero>] "Looking for allies to storm the portal!"`
- **Use case**: RP announcements, looking for group, character dialogue
- **Icon**: Speech bubble or RP mask

### 2. Tavern Rumor (Anonymous)
- **Purpose**: Spreading gossip, jokes, or general chatter without attribution
- **Attribution**: "A traveler whispers..." (anonymous)
- **Visual**: Purple/arcane border, mysterious scroll style
- **Format**: `A traveler whispers: "Heard there's treasure in Hellfire..."`
- **Use case**: Jokes, gossip, anonymous tips, tavern talk
- **Icon**: Scroll or whisper icon

---

## Data Model Changes

### New Activity Types

```lua
-- Current
ACTIVITY = {
    STATUS = "STATUS",   -- RP status change (auto)
    RUMOR = "RUMOR",     -- Manual post (currently shows name)
    ...
}

-- Proposed
ACTIVITY = {
    STATUS = "STATUS",      -- RP status change (auto) - KEEP
    IC_POST = "IC_POST",    -- In-character post (shows identity)
    ANON_RUMOR = "ANON",    -- Anonymous rumor (no attribution)
    ...
}
```

### Wire Protocol

| Type | Code | Data Format | Example |
|------|------|-------------|---------|
| IC Post | `IC` | text (100 char max) | `ACT:1:IC:Thrall:WARRIOR:Looking for raid:1705334400` |
| Anonymous | `ANON` | text (100 char max) | `ACT:1:ANON:Thrall:WARRIOR:Heard treasure in caves:1705334400` |

**Note**: Anonymous posts still include sender info in wire format (for rate limiting/blocking) but the **UI hides the sender**.

---

## UI Changes

### 1. Popup Redesign ("+ Share" Button)

Replace current two-tab popup with clearer options:

```
┌─────────────────────────────────────────┐
│              TAVERN BOARD               │
│         Share with Fellow Travelers     │
├─────────────────────────────────────────┤
│                                         │
│  [==============================]       │
│  |  What's on your mind?       |       │
│  [==============================]       │
│                                  56/100 │
│                                         │
│  HOW TO POST:                           │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ [*] IC POST (As Your Character) │    │
│  │     Your name & title shown     │    │
│  │     "Speaking as Thrall"        │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ [ ] TAVERN RUMOR (Anonymous)    │    │
│  │     "A traveler whispers..."    │    │
│  │     Your identity hidden        │    │
│  └─────────────────────────────────┘    │
│                                         │
│         [Cancel]        [Post]          │
└─────────────────────────────────────────┘
```

**Key differences from current:**
- Radio button selection between IC Post and Anonymous Rumor
- Clear preview of how the post will appear
- Same text input for both types
- Single "Post" button (no separate tabs)

### 2. Feed Row Styling

#### IC Post Row
```
┌─────────────────────────────────────────────────────┐
│ [Portrait] [CLASS]  Thrall <Hero>              2m ▼ │
│            "Looking for allies to storm Karazhan!"  │
│                                           [Mug: 3]  │
└─────────────────────────────────────────────────────┘
```
- **Border**: Fel green (#20FF20) with subtle glow
- **Icon**: Class icon or custom portrait
- **Name**: Full name with title in gold
- **Text**: White, quoted

#### Anonymous Rumor Row
```
┌─────────────────────────────────────────────────────┐
│ [Scroll]  A traveler whispers...               5m ▼ │
│           "Heard there's treasure in the caves..."  │
│                                           [Mug: 1]  │
└─────────────────────────────────────────────────────┘
```
- **Border**: Arcane purple (#9B30FF) with mystery vibe
- **Icon**: Scroll or whisper icon
- **Attribution**: "A traveler whispers..." (italicized, grey)
- **Text**: White, quoted

#### Status Change Row (Automatic)
```
┌─────────────────────────────────────────────────────┐
│ [Mask]   Thrall is now In Character            1h ▼ │
│          Ready for roleplay!                        │
└─────────────────────────────────────────────────────┘
```
- **Border**: Based on status color (green=IC, grey=OOC, pink=LF_RP)
- **Format**: Simple status announcement
- **No mug button** (status changes aren't "muggable")

### 3. Feed Filtering

Add filter chips at top of feed:

```
[All] [IC Posts] [Rumors] [Boss Kills] [Achievements]
```

Users can filter to see only certain activity types.

---

## Implementation Phases

### Phase A: Data Model (ActivityFeed.lua)
1. Add `IC_POST` and `ANON` to ACTIVITY enum
2. Update `CreateActivity()` to handle new types
3. Update `SerializeActivity()` / `ParseActivity()` for wire protocol
4. Update `FormatActivity()` with new display strings
5. Keep backward compatibility with old `RUMOR` type (treat as IC_POST)

### Phase B: Posting API (ActivityFeed.lua)
1. Rename `PostRumor(text)` to `PostMessage(text, isAnonymous)`
2. Create `PostICMessage(text)` convenience wrapper
3. Create `PostAnonymousRumor(text)` convenience wrapper
4. Both share same cooldown (5 min between ANY posts)
5. Both broadcast immediately (force broadcast)

### Phase C: Popup UI (Journal.lua)
1. Redesign `GetRumorPopup()` with radio buttons
2. Remove tab system (IC/Status tabs)
3. Add radio button group: "IC Post" vs "Anonymous Rumor"
4. Preview text shows how post will appear
5. Single "Post" button calls appropriate API

### Phase D: Feed Row Display (Journal.lua)
1. Update `CreateFeedRow()` to style differently by type
2. IC_POST: Green border, class icon, full name+title
3. ANON: Purple border, scroll icon, "A traveler whispers..."
4. STATUS: Colored border by status, no mug button
5. Add visual polish (border glow, icons)

### Phase E: Filtering & Polish
1. Add filter chips to feed header
2. Filter state in `socialUI.feed.filter`
3. Update "empty state" messages per filter
4. Ensure real-time listener updates work with filters

---

## Constants to Add (Constants.lua)

```lua
C.FEED_POST_TYPES = {
    IC_POST = {
        id = "IC_POST",
        label = "In Character",
        description = "Post as your character",
        icon = "Interface\\Icons\\Spell_Holy_MindSoothe",
        borderColor = { 0.2, 0.8, 0.2 },  -- Fel green
        attribution = function(player, title)
            if title then
                return string.format("%s <%s>", player, title)
            end
            return player
        end,
    },
    ANON_RUMOR = {
        id = "ANON",
        label = "Tavern Rumor",
        description = "Post anonymously",
        icon = "Interface\\Icons\\INV_Scroll_01",
        borderColor = { 0.61, 0.19, 1.0 },  -- Arcane purple
        attribution = function() return "A traveler whispers" end,
    },
}

C.FEED_FILTER_OPTIONS = {
    { id = "all", label = "All" },
    { id = "ic", label = "IC Posts" },
    { id = "anon", label = "Rumors" },
    { id = "boss", label = "Boss Kills" },
    { id = "badge", label = "Achievements" },
}
```

---

## Migration Path

1. Existing `RUMOR` activities in saved data → Treat as `IC_POST` (they showed name)
2. Existing `STATUS` activities → Keep as-is (unchanged)
3. Old addon versions receiving new types → They see "Unknown activity" (graceful degradation)

---

## Open Questions

1. **Should anonymous rumors show the class?**
   - Option A: Hide class too (fully anonymous)
   - Option B: Show class icon only (gives some flavor)
   - **Recommendation**: Hide class for true anonymity

2. **Should status changes be muggable?**
   - Current: Yes
   - Proposed: No (status changes are informational, not content)
   - **Recommendation**: Remove mug button from STATUS rows

3. **Rate limit: separate or shared?**
   - Current: 5 min cooldown for rumors
   - Option A: Separate 5 min cooldowns (IC + Anon = 2 posts/5 min)
   - Option B: Shared cooldown (1 post of any type per 5 min)
   - **Recommendation**: Shared cooldown (prevents spam regardless of type)

4. **Anonymous post to self: show your own name?**
   - Option A: You see "A traveler whispers..." like everyone else
   - Option B: You see "You whispered: ..." with your name
   - **Recommendation**: Option B so you can track your own posts

---

## Files to Modify

| File | Changes |
|------|---------|
| `Core/Constants.lua` | Add FEED_POST_TYPES, FEED_FILTER_OPTIONS |
| `Social/ActivityFeed.lua` | New activity types, PostMessage API, FormatActivity updates |
| `Journal/Journal.lua` | Popup redesign, CreateFeedRow styling, filter chips |
| `CLAUDE.md` | Document new system |

---

## Success Criteria

1. Users can clearly choose between "speaking as character" and "anonymous gossip"
2. Feed visually distinguishes post types at a glance
3. Anonymous posts truly hide sender identity in UI (but not wire protocol)
4. Backward compatible with existing saved activities
5. Real-time listener updates continue working
6. Cooldowns prevent spam regardless of post type
