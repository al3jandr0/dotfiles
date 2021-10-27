import XMonad
import qualified XMonad.StackSet as W
import System.Exit (exitSuccess)

import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextWS, prevWS)
import XMonad.Actions.WithAll (sinkAll, killAll)

import XMonad.Layout.Accordion ( Accordion(Accordion) )

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))

--import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.ResizableTile ( ResizableTall(ResizableTall) )
import XMonad.Layout.ThreeColumns ( ThreeCol(ThreeCol) )
import XMonad.Actions.MouseResize ( mouseResize )

-- Layouts modifiers
import XMonad.Layout.Hidden
import XMonad.Layout.LayoutModifier ( ModifiedLayout )
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances ( StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders ( smartBorders, withBorder )
import XMonad.Layout.Renamed ( renamed, Rename(Replace) )
import XMonad.Layout.Simplest ( Simplest(Simplest) )
import XMonad.Layout.Spacing
    ( spacingRaw, Border(Border), Spacing )
import XMonad.Layout.SubLayouts ( subLayout )
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe, hPutStrLn)
import XMonad.Util.SpawnOnce

myBorderWidth :: Dimension
myBorderWidth = 4           -- Sets border width for windows

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
           -- $ mySpacing 0 
           $ smartBorders
           $ ResizableTall 1 (3/100) (1/2) []

-- The layout hook
myLayoutHook = avoidStruts $ hiddenWindows $ T.toggleLayouts tall
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) tall 

myKeys :: [(String, X ())]
myKeys  = 
    -- Xmonad
    [ ("M-S-q", io exitSuccess)     -- quits xmonad
    -- power options
    , ("M-S-r", spawn "systemctl reboot") 
    , ("M-S-s", spawn "systemctl suspend")
    , ("M-S-p", spawn "systemctl poweroff")

    -- launch
    , ("M-o", spawn "dmenu_run -i -b -p \"Run: \"")     -- dmenu
    , ("M-<Return>", spawn "alacritty")     -- launch terminal. TODO: remove hardcoded terminal application
    , ("M-b", spawn "firefox")     -- launch browser. TODO: remove hardcoded firefox

    -- Windows
    , ("M-m", withFocused hideWindow)     -- hides focused window 
    , ("M-S-m", popOldestHiddenWindow) 
    , ("M-c", kill)     -- kill the currently focused window
    , ("M-S-a", killAll)   -- Kill all windows on current workspace
    , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
    -- Workspaces:
    --, ("M-/", nextNonEmptyWS)  -- Switch focus to next non-empty monitor
    --, ("M-S-/", prevNonEmptyWS)  -- Switch focus to previous non-empty monitor
    , ("M-.", nextWS)  -- Switch focus to next monitor
    , ("M-,", prevWS)  -- Switch focus to prev monitor

    -- Specila function keys
    , ("<XF86MonBrightnessUp>"  , spawn "brightnessctl --class backlight set +10%")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl --class backlight set 10%-")
    , ("<XF86AudioRaiseVolume>" , spawn "amixer set Master on && amixer set Master 20%+")
    , ("<XF86AudioLowerVolume>" , spawn "amixer set Master 20%-")
    , ("<XF86AudioMute>"        , spawn "amixer set Master toggle")
    , ("<XF86KbdLightOnOff>"    , spawn "toggle-kb-backlight")
    ]

main :: IO ()
main = do
    xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"
    xmonad $ ewmh def 
        { terminal           = "alacritty"
        , modMask            = mod4Mask
        , borderWidth        = myBorderWidth
        , manageHook         = manageDocks
        -- , handleEventHook    = handleEventHook def <+> docksEventHook <+> fullscreenEventHook
        , handleEventHook    = docksEventHook 
        , startupHook        = setWMName "LG3D"
        , layoutHook         = myLayoutHook
        , normalBorderColor  = "#333333"
        , focusedBorderColor = "#08E8DE" --"#AFAF87"
        , logHook = dynamicLogWithPP $ xmobarPP 
              { ppOutput = hPutStrLn xmproc
              , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"           -- Current workspace
              , ppVisible = xmobarColor "#98be65" ""               -- Visible but not current workspace
              , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" -- Hidden workspaces
              , ppHiddenNoWindows = xmobarColor "#c792ea" ""      -- Hidden workspaces (no windows)
              , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window
              , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separator character
              , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
              , ppOrder  = \(ws:l:t:ex) -> [l,ws]++ex++[t]                    -- order of things in xmobar
              }

        --, focusedBorderColor = "#46d9ff"
        --, normalBorderColor  = "#282c34" 
        }  `additionalKeysP` myKeys

