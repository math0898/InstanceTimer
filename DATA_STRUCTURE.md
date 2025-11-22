# InstanceTimer Data Structure

This document describes the data structure used by InstanceTimer to store run history, personal bests, and best segments.

## Overview

InstanceTimer stores all data in the `InstanceTimerSaved` variable, which is automatically saved by World of Warcraft between game sessions (as defined in `InstanceTimer.toc` with `SavedVariables: InstanceTimerSaved`).

## Data Structure

```lua
InstanceTimerSaved = {
    Version = "1.1",
    Data = {
        [dungeonName] = {
            [className] = {
                personalBest = {
                    finalTime = number,      -- Total time in seconds
                    segments = { number, ... },  -- Time for each boss/segment in seconds
                    segmentNames = { string, ... },  -- Names of each segment
                    date = string            -- Date/time of the run
                },
                bestSegments = {
                    [segmentName] = number   -- Best time for this specific segment
                },
                history = {
                    -- Array of up to 50 most recent runs, newest first
                    {
                        finalTime = number,
                        segments = { number, ... },
                        segmentNames = { string, ... },
                        date = string
                    },
                    ...
                }
            }
        }
    }
}
```

## Example

```lua
InstanceTimerSaved = {
    Version = "1.1",
    Data = {
        ["The Rookery"] = {
            ["WARRIOR"] = {
                personalBest = {
                    finalTime = 480,  -- 8 minutes
                    segments = {120, 180, 180},
                    segmentNames = {"First Boss", "Second Boss", "Third Boss"},
                    date = "2025-11-22 14:30:00"
                },
                bestSegments = {
                    ["First Boss"] = 110,   -- Best segment even if not in PB run
                    ["Second Boss"] = 170,
                    ["Third Boss"] = 180
                },
                history = {
                    {finalTime = 480, segments = {...}, segmentNames = {...}, date = "..."},
                    {finalTime = 495, segments = {...}, segmentNames = {...}, date = "..."},
                    -- ... up to 50 runs
                }
            },
            ["MAGE"] = {
                -- Similar structure for Mage class
            }
        },
        ["Dire Maul"] = {
            -- Similar structure for other dungeons
        }
    }
}
```

## Valid Classes

The following are the 13 valid World of Warcraft class names (as returned by the game API):
- WARRIOR
- PALADIN
- HUNTER
- ROGUE
- PRIEST
- DEATHKNIGHT
- SHAMAN
- MAGE
- WARLOCK
- MONK
- DRUID
- DEMONHUNTER
- EVOKER

## Database Functions

### Core Functions

- `InstanceTimer.Database.SaveRun(instance, class, segments, segmentNames, finalTime)` - Save a completed run
  - Returns: 1 if PB, 0 if not PB, -1 if invalid
  
- `InstanceTimer.Database.GetRun(instance, class)` - Get the personal best run
  - Returns: run object or nil
  
- `InstanceTimer.Database.IsRunValid(instance, class, segments, segmentNames, finalTime)` - Validate run data
  - Returns: boolean

### Segment Functions

- `InstanceTimer.Database.GetBestSegment(instance, class, segmentName)` - Get best time for a specific segment
  - Returns: number (seconds) or nil
  
- `InstanceTimer.Database.GetAllBestSegments(instance, class)` - Get all best segments
  - Returns: table of {segmentName = time}
  
- `InstanceTimer.Database.IsSegmentPB(instance, class, segmentName, segmentTime)` - Check if segment is a PB
  - Returns: boolean
  
- `InstanceTimer.Database.GetSumOfBest(instance, class)` - Get theoretical best time (sum of all best segments)
  - Returns: number (seconds)

### History Functions

- `InstanceTimer.Database.GetHistory(instance, class)` - Get run history
  - Returns: array of run objects (newest first, max 50)
  
- `InstanceTimer.Database.GetAllPBsForClass(class)` - Get all PBs for a class across all dungeons
  - Returns: table of {dungeonName = run object}

## Integration with Main Timer

When a player exits a dungeon, the `OnInstanceChangeListener` in `main.lua`:
1. Calls `InstanceTimer.Database.SaveRun()` with the completed run data
2. Colors the timer green if it's a PB, red if it's not
3. The run is automatically added to history and best segments are updated
