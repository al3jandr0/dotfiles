import XMonad
import qualified XMonad.StackSet as W
import System.Exit (exitSuccess)

import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextWS, prevWS)
import XMonad.Actions.WithAll (sinkAll, killAll)

import XMonad.Layout.Accordion ( Accordion(Accordion) )

import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))

--import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.ResizableTile ( ResizableTall(ResizableTall) )
import XMonad.Layout.ThreeColumns ( ThreeCol(ThreeCol) )
import XMonad.Actions.MouseResize ( mouseResize )

-- Layouts modifiers
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
myBorderWidth = 2           -- Sets border width for windows


-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
--mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
--mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True


tall     = renamed [Replace "tall"]
           -- $ mySpacing 4
           -- $ smartBorders
           $ ResizableTall 1 (3/100) (1/2) []
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ ThreeCol 1 (3/100) (1/2)
tallAccordion  = renamed [Replace "tallAccordion"] Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion


-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts tall
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| threeCol
                                 ||| tallAccordion
                                 ||| wideAccordion

myKeys :: [(String, X ())]
myKeys  = 
    -- Xmonad
    [ ("M-S-q", io exitSuccess)     -- quits xmonad

    , ("M-o", spawn "dmenu_run -i -b -p \"Run: \"")     -- dmenu
    , ("M-<Return>", spawn "alacritty")     -- launch terminal. TODO: remove hardcoded terminal application
    , ("M-b", spawn "firefox")     -- launch browser. TODO: remove hardcoded firefox

    , ("M-c", kill)     -- kill the currently focused window 
    , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- Workspaces
    , ("M-.", nextWS)  -- Switch focus to next monitor
    , ("M-,", prevWS) ]  -- Switch focus to prev monitor


--clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
--    where i = fromJust $ M.lookup ws myWorkspaceIndices

--myStartupHook = do
--    spawnOnce "trayer --edge bottom --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
--    spawnOnce "volumeicon &"

main :: IO ()
main = do
    xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"
    xmonad $ def 
        { terminal           = "alacritty"
        , modMask            = mod4Mask
        , borderWidth        = 4 
        , manageHook         = manageDocks
        , handleEventHook    = docksEventHook
        , startupHook        = setWMName "LG3D"
        --, layoutHook         = avoidStruts $ withBorder 2 $ ResizableTall 1 (3/100) (1/2) [] 
        , layoutHook         = avoidStruts tall
        , normalBorderColor  = "#333333"
        , focusedBorderColor = "#AFAF87"
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

