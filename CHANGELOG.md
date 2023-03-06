*In compliance with the [GPL-3.0](https://opensource.org/licenses/GPL-3.0) license: I declare that this version of the program contains my modifications, which can be seen through the usual "git" mechanism.*  


2022-10  
Contributor(s):  
Carter Li  
Yuze Jiang  
>Update VideoView.swift  
>Fix white window after entering PIP when pausing (#3973)* Fix white window after entering PIP when pausing

We need to redraw a frame after entering PIP when pausing, and
previously we perform such redraw in the next `layout`. However,
it now takes two `layout`s before finishing entering PIP. This was
tested on macOS 13 beta and macOS 12.6.

Changing the pending flag into a counter and redrawing twice
solve the problem.

* Change variable name upon review  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-09  
Contributor(s):  
low-batt  
>Fix NSFileHandleOperationException crash in logger, #3590The commit in the pull request will:- Add a new Lock class- Change Logger to use a lock to coordinate closing of the log file- Change Logger to not use `Utilities` methods that call back into  the logger- Change Logger to catch and handle exceptions thrown by file  operations- Remove logDirURL from Utilities- Change PrefAdvancedViewController to use Logger.logDirectory  instead of Utilities.logDirURLThese changes address multiple ways in which the logger can causeIINA to crash.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-08  
Contributor(s):  
李通洲  
decodism  
low-batt  
>HDR: allow HDR mode for SDR videos  
>screenshot: supports webp and jxl ( not working yet )  
>The commit in the pull request will:- Change SleepPreventer.preventSleep to only display an alert once per  IINA invocation- Change Utility.showAlert to support a suppression button- Add a button to the alert to allow the user to permanently suppress  the alert- Change the alert to include the error code returned by macOS- Add a button in Preferences/Utilities to restore suppressed alertsAdditional text was added requiring localization.This fixes how IINA reports a macOS power management failure.The root cause of the failure is in macOS and must be fixed by Apple.  
>Fix top of progress bar not behaving as such, #3911The commit in the pull request will:- Change MainWindowController methods playSliderChanges and  updateTimeLabel to position the time preview relative to the progress  bar- Add method canShowThumbnailAbove to MainWindowController- Change updateTimeLabel to use canShowThumbnailAbove- Change PlaySliderCell.awakeFromNib to set slider control size to small  for macOS 11+- Increase bottom and top constraints around progress bar from 4.5 to 6These changes stop the time preview from intruding into the progress barin the on screen controller.  
>Close option to start iina-cli in music-mode, #3651The commit in the pull request will:- Add a new enterMusicMode property to the CommandLineStatus struct- Add support for a new --music-mode option to the  AppDelegate.parseArguments method- Add code to applicationDidFinishLaunching to switch to the mini player  if the music-mode option is specified- Add the new --music-mode option to the output of the --help option  
>Update rightLabel when clicked while player paused  
>Upgrade to MPV git-head  
>Update the seek OSD with the actual position of the video  
>Fix Error Cannot prevent display sleep!, #3842The commit in the pull request will:- Change SleepPreventer.preventSleep to only display an alert once per  IINA invocation- Change Utility.showAlert to support a suppression button- Add a button to the alert to allow the user to permanently suppress  the alert- Change the alert to include the error code returned by macOSAdditional text was added to the alert's message requiring localization.This fixes how IINA reports a macOS power management failure.The root cause of the failure is in macOS and must be fixed by Apple.  
>Avoid clicking on leftLabel sets showRemainingTime to false  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-07  
Contributor(s):  
Tomii Poll  
Matt Svoboda  
李通洲  
>Fix #3857: Enter Full Screen exists under 2 different menu items  
>Split KeyMapping's "key" field into "rawKey" and "normalizedMpvKey", and change use to one or the other appropriately. Improve and expand logic for normalizing MPV key sequences. Add logic to skip over "default bindings start" and ignore bindings which specify non-default input sections.  
>Add OSD message  
>Make shuffle toggleableAdd menu item tooToggling shuffle off sends MPV's unshuffle command  
>Inspector: Detect HDR mode more accurately  
>Inspector: Show pixel format info  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-06  
Contributor(s):  
Matt Svoboda  
李通洲  
low-batt  
>HDR: Support tone mapping settings  
>HDR: Observe `MPVProperty.videoParams*` directly to avoid possible race conditions.Ref: https://github.com/iina/iina/issues/3806#issuecomment-1154518956  
>HDR: Remove unnecessary `level: .debug`  
>Fix Saved Audio Filters disabled in music mode, #3818This commit will:- Move menuToggleVideoFilterString from MainWindowMenuActions  to MainMenuActionHandler- Move menuToggleAudioFilterString from MainWindowMenuActions  to MainMenuActionHandler- Change MenuController to call the methods in their new  location  
>Fix adjust remaining time with playback speed, #3814The commit in the pull request will:- Change DurationDisplayTextField.updateText to take a playSpeed  parameter- Change updateText to adjust the remaining time based on the speed- Change PlayerWindowController.updatePlayTime to pass the playback  speed to updateText  
>Fix bug: Playback History searches always return no results if the query contains an uppercase letter  
>HDR: Add `Enable HDR mode by default` preference checkboxRef: https://github.com/iina/iina/issues/3808  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-05  
Contributor(s):  
pan93412  
Jesse Chan  
>l10n: zh-Hant: review & translate new strings- I translated IINA with the latest `xcloc` format from Apple Xcode, instead of editing .strings directly.- Therefore, the string seems reordered. It won't affect the actual effect.  
>Focus the window to ensure cursor can be hidden in fullscreen"NSCursor.setHiddenUntilMouseMoves" is only effective when thecalling window is the focused window.When user moves back from another screen or space, the window maynot be focused. As a result, the cursor can't be hidden before theuser clicks the window.It can be reasonably expected that the user would want to focus onthe window when the mouse moves inside the window and the window isin fullscreen.As such, focus the window on mouse movement inside the window whenthe window is in fullscreen.Bug: #1415  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-04  
Contributor(s):  
low-batt  
>Fix custom key binding ignored, #3692The commit in the pull request will:- Add swift-algorithms to the list of packages- Change MenuController.updateKeyEquivalentsFrom to ignore key bindings  that have been overridden when searching for keys to be used as  shortcuts for menu items  
>Update icons to adhere to latest HIGIn macOS Big Sur Apple introduced many user interface changes. Thechanges included changing the requirements for app and document iconsspecified in the Human Interface Guidelines. The commit updates IINA'sapp icon and all of the document icons to adhere to the current HIG.The changes are subtle. See IINA discussion #3670.Thank you @Zabriskije for creating the updated icons.This commit will:- Update the app icon- Update all of the document icons  
>Fix IINA is not associated with GIF files, #3679The commit in the pull request will:- Add a document type entry for GIF files to Info.plist- Add document icons for GIF files as Assets  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-03  
Contributor(s):  
low-batt  
>Add a debugDescription property to mpv_nodeThis commit will extend mpv_node to add a custom debugDescriptionproperty that provides a textual representation of the node suitable fordeveloper debugging.This allows developers to add temporary debug logging such as:mpv_get_property(mpv, MPVProperty.af, MPV_FORMAT_NODE, &node)Logger.log("mpv_get_property af:\n\(String(reflecting: node))")In order to see the full node tree returned by mpv.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-02  
Contributor(s):  
Carter Li  
李通洲  
low-batt  
>HDR: Correctly disable HDR mode when switch to SDR content in playlist  
>Fix currently open filenames not syncing, iina#3159This problem is due to a defect in AppKit that has been fixed in macOSMonterey. The commit changes the window controller to apply aworkaround of reseting the window's title in earlier versions of macOS.If the title is not reset when a window is reused then the wrong titlewill be displayed in the "Window" menu.The commit will:- Change MainWindowController.windowWillOpen to set the window's title  to "Window", the title a NSWindow has by default  
>Use the latest MPV headers  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2022-01  
Contributor(s):  
李通洲  
low-batt  
>PlaylistView: Store preference for playlist loop status and add a `loop file` button  
>Fix fix for CPU is consumed by OSC while hidden, iina#3601The initial fix would sometimes trigger a main thread hang in`mpv_get_property`. The working theory is that `syncUITime` is being calledbefore mpv had finished loading the video.This commit will:- Change MainWindowController.showUI to only sync the UI and start the  timer if mpv has completed loading the video  
>FFmpegController: Fix compiler warnings  
>Fix CPU is consumed by OSC while hidden, iina#3601This commit will:- Change MainWindowController.hideUI to stop the timer that updates  the OSC- Change MainWindowController.showUI to sync the UI and start the timer- Change PlaybackInfo.constrainVideoPosition to check that`videoPosition  is not nil  
>Update fix for CPU is consumed by OSC while hidden iina#3601This commit will add a isSyncTimerStopped boolean property toMainWindowController. This flag is used to keep track of whetherthe timer that synchronizes the UI is running or not.  
>Add AppleScript supportThanks Wevah: https://github.com/iina/iina/pull/2857  
>Crash in NowPlayingInfoManager during quit, #3607The commit will add a guard statement to the updateInfo method inNowPlayingInfoManager to check if mpv termination has been initiated.  
>Fix NSFileHandleOperationException crash, #3590This commit will:- Change AppDelegate.applicationShouldTerminate to use a copy of  playerCores in the background thread- Add logging to AppDelegate.applicationShouldTerminate to debug a  hang during termination- Add logging to MPVController methods mpvQuit and handleEvent to  also help debug the problem  
>Add log messages for debugging shutdown problem, #3590  
>Fix deadlock in VideoView.uninit method, #11This commit will add locking of the OpenGL context to the VideoView.uninitmethod in order to match the order of lock acquisition the ViewLayer.drawmethods use.  
>Fix deadlock in ViewLayer.draw methods, #11Resolved merge conflicts.The commit changes the order of acquiring locks in both of the ViewLayer drawmethods to first lock the OpenGL context before locking uninitLock.  
>Backout fix for CPU is consumed by OSC while hidden iina#3601This commit will remove the changes added to MainWindowController. tofix the issue with CPU being consumed by the OSC while hidden.The fix introduced a main thread hang in mpv_get_property called fromPlayerCore.syncUI while running on a timer.This issue is not critical. Fixing it saves a small amount of energy, so desirableto eventually fix the issue. Unfortunately I have not been able to reproducethe hang. Need to figure out how to trigger the problem before proposingany fix. Backing out faulty fix to stabilize IINA-Plus.  
>HDR: Use itur_2100_* to follow Apple's suggestion  
>Update copyright year to 2022The copyright year displayed in the about window and the macOS "Get Info"window for the application should reflect the year in which the particularrelease of the application was built.Apparently from a legal perspective updating the copyright year is no longerrequired. But users are used to the copyright matching up with the year of thebuild and this does provide the user with useful information about the age ofthe release. Therefore IINA should continue to update the copyright year.This commit will:- Update the copyright year to 2022- Add a bash script "update_copyright.sh" to the other directory  
>MiniPlayer: Fix iina-plus/iina#18 by moving window up on initial  
>Danmaku: Initial support ( experimental )  
>HDR: Remove MDCV related logic againRef: https://github.com/iina-plus/iina/issues/8#issuecomment-1021925076  
>Merge remote-tracking branch 'Wevah/applescript' into developAppleScript support: https://github.com/iina/iina/pull/2857  
>Fix screenshot crash with long video title, iina#3334This commit will:- Extend URL with a new optional computed property, creationDate- Change the method Utility.getLatestScreenshot to use the array max method  to find the latest screenshot file  
>Fix legacy fullscreen is broken (11.0.1), iina#3211The commmit will add a mouseUp method to the VideoView class that callsMainWindowController.mouseUp. This is needed because adding a title tothe window after having removed it while in full screen mode causes AppKitto stop calling the mouseUp method in the controller.  
>MiniPlayer: Fix #18 by moving window up on initial  
>Fix NSFileHandleOperationException crash, #3590This commit will:- Add the package swift-atomics- Change the PlayerCore property isMpvTerminating to be a computed  property that uses a ManagedAtomic property as the backing propertyThis change ensures that when this property is set by the main thread thenew value is immediately available to the mpv controller threads inMPVController.  
>Closes update copyright year to 2022 iina#3598This commit will:- Add a new method Utility.iinaCopyright that returns the copyright  contained in the Info.plist- Change AppDelegate.applicationWillFinishLaunching to use the new  method to obtain the copyright and log it  
>Don't embed yt-dlp.  
>PlaylistView: Make `loop file` actually work and add a `loop file` button  
>PlaylistView: Store preference for playlist loop statusFix https://github.com/iina-plus/iina/issues/24  
>Reducing the number of dispatching blocksMay relate to https://github.com/iina-plus/iina/issues/17  
>Fix camera housing blocks controller, iina#3558The commit in the pull request will:- Extend NSScreen with a new optional computed property,  cameraHousingHeight- Change MainWindowController.legacyAnimateToFullscreen to check if  cameraHousingHeight indicates a camera housing intrudes into the  screen and if so reduces the size of the full screen video window's  view's frame appropriately.- Add NSPrefersDisplaySafeAreaCompatibilityMode set to false to  Info.plist now that IINA properly handles the camera housing  
>Fix screenshot crash with long video title, iina#3334This commit will address review comments on the changes to the methodsMPVController.handleEvent and Utility.getLatestScreenshot.  
>Fix deadlock in ViewLayer.draw methods, #11The commit changes the order of acquiring locks in both of the ViewLayer drawmethods to first lock the OpenGL context before locking uninitLock.  
>Remove mask window when main window closes, #3558This is an update to the fix for issue #3558If the use legacy full screen preference is enabled then when in full-screenmode on a Mac with a camera housing that intrudes into the screen IINAdisplays a black window behind the main window blacks out the screen to theleft and right of the camera. IINA was failing to close that window whenexiting the application while in full-screen mode.This commit will add code to MainWindowController.windowWillClose toclose the mask window if present.  
>Preference: move `Load ICC profile` switch to codec tab; add `Use mastering display metadata` switch  
>Add AppleScript supportResolved merge conflicts.Thanks Wevah: https://github.com/iina/iina/pull/2857  
>HDR: Fix https://github.com/iina-plus/iina/issues/15  
>Fix NSFileHandleOperationException crash, #3590This commit will:- Add a isMpvContextValid property to MPVController to suppress calls to  mpv when shutting down- Add a isQuitting property to MPVController to keep track of having sent  a quit command to mpv- Add a isShutdown property to MPVController to keep track of mpv  shutting down due to "q" being typed in the window- Change applicationShouldTerminate in AppDelegate to detect if mpv has  shutdown and if so immediately proceed with termination  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-12  
Contributor(s):  
Collider LI  
李通洲  
Nate Weaver  
low-batt  
>Add HDR and configurable thumb width support  
>Honor `Enable advanced settings` configRef: https://github.com/iina-plus/iina/issues/8#issuecomment-999799223  
>Fix camera housing blocks controller, iina#3558The commit in the pull request:- Extends NSScreen with a new optional computed property,    cameraHousingHeight- Adds a new class CameraAreaMaskWindow that is used to black out the    area of the screen to the left and right of the camera housing- Changes MainWindowController.legacyAnimateToFullscreen to check if    cameraHousingHeight indicates a camera housing intrudes into the    screen and if so reduce the size of the full screen video window    appropriately and put up a black window to hide the wallpaper on    either side of the camera housing- Changes MainWindowController.legacyAnimateToWindowed to close the    window masking the area around the camera housing if displayed- Adds NSPrefersDisplaySafeAreaCompatibilityMode set to false to    Info.plist  
>Fix NSInvalidArgumentException crash, #3584The commit in the pull request corrects a crash due to aNSInvalidArgumentException being thrown by theNowPlayingInfoManager.updateInfo method as a result of multiple threadschanging the same dictionary at the same time. The commit updates theNowPlayingInfoManager class to be thread safe.  
>Revert "HDR: Remove unused code in FFmpegController"This reverts commit 4b5f0b9ad3d50d6738a47a017a5c70e78eecce84.  
>Fix pause the video and the program crashes, #3475Corrected merge conflicts.The commit in the pull request:- Adds a context property to ViewLayer for the OpenGL context- Changes MPVController.mpvInitRendering to save the OpenGL context- Changes ViewLayer.draw to use the saved context  
>Fix crash in mpv_set_property during termination, #11This was also reported against IINA in issue iina#3596The commit in the pull request will:- Rename the PlayerCore property isMpvTerminated to isMpvTerminating to  reflect that termination has been initiated and being processed  asynchronously- Change existing references to  isMpvTerminated  to use new name- Change PlayerCore.terminateMPV to set isMpvTerminating to true right  before starting the termination process- Change PlayerCore.syncUI to do nothing if mpv is terminating- Change MPVController.mpvQuit to remove observers MPVController  registered before sending the quit command to mpv- Change many MPVController methods to check to see if mpv is being  terminated  
>Fix quit triggers "invalid context state" error, #3593The commit in the pull request:- Adds an openGLContext property to MPVController for the OpenGL  context- Changes MPVController.mpvInitRendering to save the OpenGL context- Adds a new method lockAndSetOpenGLContext to MPVController- Adds a new method unlockOpenGLContext to MPVController- Changes MPVController.mpvUninitRendering to use the new methods to  appropriately manage the OpenGL context  
>Merge remote-tracking branch 'xj/danmaku' into develop# Conflicts:#	README.md#	deps/executable/youtube-dl#	iina.xcodeproj/project.pbxproj#	iina.xcodeproj/xcshareddata/xcschemes/OpenInIINA.xcscheme#	iina.xcodeproj/xcshareddata/xcschemes/iina-ca.xcscheme#	iina.xcodeproj/xcshareddata/xcschemes/iina-cli.xcscheme#	iina.xcodeproj/xcshareddata/xcschemes/iina.xcscheme#	iina/AboutWindowContributorAvatarItem.swift#	iina/AboutWindowController.swift#	iina/AssrtSubtitle.swift#	iina/Base.lproj/PrefGeneralViewController.xib#	iina/JustXMLRPC.swift#	iina/MPVController.swift#	iina/OpenSubSubtitle.swift#	iina/ShooterSubtitle.swift  
>Fix exception when built using Xcode 13  
>Fix SUUpdater  
>Fix NSFileHandleOperationException crash, #3590The fix changes IINA to wait for mpv to cleanly shutdown before proceedingwith application shutdown.The commit in the pull request:- Adds a isDestroyed semaphore to MPVController- Changes MPVController.handleEvent to signal the semaphore once the  mpv context has been destroyed- Adds a waitForDestruction method to  MPVController to wait for mpv to  be destroyed- Adds a waitForTermination method to PlayerCore that calls  MPVController.waitForDestruction to wait for mpv to be destroyed- Changes AppDelegate.applicationShouldTerminate to submit a task to wait  for all players to terminate- Changes applicationShouldTerminate to return terminateLater to tell the  framework to hold up application termination until told to proceed  
>Merge remote-tracking branch 'sidneys/feature/save-youtube-playlist-items' into develop  
>Fix quit triggers "invalid context state" error, #3593Resolve additional merge conflicts.The commit in the pull request:- Adds an openGLContext property to MPVController for the OpenGL  context- Changes MPVController.mpvInitRendering to save the OpenGL context- Adds a new method lockAndSetOpenGLContext to MPVController- Adds a new method unlockOpenGLContext to MPVController- Changes MPVController.mpvUninitRendering to use the new methods to  appropriately manage the OpenGL context  
>Fix pause the video and the program crashes, #3475The commit in the pull request:- Adds a context property to ViewLayer for the OpenGL context- Changes MPVController.mpvInitRendering to save the OpenGL context- Changes ViewLayer.draw to use the saved context  
>HDR: don't query HDR mode before file is loaded  
>Add `Disable ICC profile` advance settingRef: https://github.com/iina-plus/iina/issues/10  
>HDR: Use MPV instead of ffmpeg to detect primaries and trcPros: Much easier to detect HDR content, including cases of switching video track, play list. HDR mode for network resources can also be detected.Cons: Display-P3 will no longer be enabled because MPV doesn't honor mastering display metadata.Fixes #6  
>Add rotation scripting propertyAlso use contains instead of firstIndex(of:) when testing for a valid rotation.  
>HDR: Remove unused code in FFmpegController  
>Fix media keys doesn't work, #3574The commit in the pull request:- Adds the ability to set the state to `NowPlayingInfoManager.updateInfo`- Eliminates the method  `NowPlayingInfoManager.updateState`- Changes  `PlayerCore.fileStarted` to set the state to `playing`- Changes references to `updateState` to use `updateInfo`  
>Use FFMPEG to check for mastering display metadata, for enabling Display-P3 primariesRef: https://github.com/mpv-player/mpv/issues/9620  
>Fix build issues  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-11  
Contributor(s):  
Akash D  
李通洲  
low-batt  
>HDR: Add HDR switch for fast toggling HDR mode  
>Fix CPU is consumed when paused, iina#3537Two systems were continuing to run when playback was paused.The commit in the pull request:- Changes `PlayerCore.pause` to invalidate the timer and stop the  display link thread- Changes `PlayerCore.resume` to create the synchronization timer  and start the display link  
>HDR: Reset colorspace when closing window  
>HDR: Disable HDR playback when the display does not support ESR mode  
>Fix legacy Full Screen is absolutely busted, iina#3543The commit in the pull request changes the method updateTitle in the classMainWindowController to use an alternative implementation when thelegacy full screen feature is enabled that avoids calling the methodNSWindow.setTitleWithRepresentedFilename. This works around a defect inthe Cocoa framework that results in IINA crashing with anNSInvalidArgumentException.  
>HDR: swiftify code  
>HDR: Fix typo  
>Merge remote-tracking branch 'xdr/develop'  
>HDR: fallback to bt.2020 instead of display p3; more memleak fixes  
>HDR: Correctly show the colorspace / primaries we are using in inspectorTurns out that `MPVProperty.videoParamsPrimaries` is the primaries encoded in video source. We now use VideoLayer.colorspace instead.  
>HDR: It turns out that MPV does support Display P3. Use it  
>HDR: Fix HDR mode is not updated when opening a new video source.  
>HDR: show trc info too  
>HDR: Display primaries info in inspector  
>HDR: find a better place to request HDR mode, to fix loading file from playlist  
>HDR: assume Display P3 when a video source doesn't provide master display metadata  
>Check if mastering exists in side frame  
>HDR: Check for frames if stream doesn't contain mastering display metadata  
>Fix  progress bar does not reach end iina#3331This commit will change the setting of PlaybackInfo.videoPosition inPlayerCore.syncUI to take into account the value of the mpv eof-reachedproperty and adjust the position accordingly if the end of the video has beenreached.  
>HDR: Restore macOS 11.11 compatibility by guarding HDR code with `#available`  
>HDR: Correct the label color in inspector  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-10  
Contributor(s):  
Jesse Chan  
xjbeta  
low-batt  
>Sparkle.  
>Replace deprecated "display-fps" with "override-display-fps"  
>Update Sparkle to 2.0.0 beta.Fix Preferences crash.  
>Alamofire ShooterSubtitle.  
>Add an option to match refresh rate in fullscreenAllow to switch to a matching refresh rate (if there is any) whenthe player goes fullscreen. This can eliminate stuttering, and, onsome external displays, enable frame interpolation.Bug: #3414  
>Alamofire AboutWindowContributor.  
>Alamofire AssrtSubtitle.  
>Xcode 13.  
>Alamofire OpenSubSubtitle.  
>Close add A-B Loop indicator on progress bar, iina#548This commit adds two additional thumbs to the progress bar representingthe A and B loop points when the A-B loop feature is active. This allowsthe user to adjust the loop points.This commit will:- Add a new class PlaySliderLoopKnob that adds an additional thumb- Add a new class PlaySlider that customizes NSSlider to add the thumbs- Change MainWindowController.xib to use PlaySlider for the OSC- Change PlayerCore to allow mpv loop points to be updated- Change MainWindowController to observe the thumbs and update mpv- Change PlayerWindowController to synchronize the thumbs with mpv- Change MainMenuActions to call the window controller for A-B Loop- Change PlaybackInfo to use an enum class for abLoopStatus- Add a new message to OSDMessage  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-09  
Contributor(s):  
low-batt  
>Fix subtitles won't show, any source, iina#3431This commit will:- Change OpenSubSubtitle.hash to throw noResult if the video is being    streamed- Change OpenSubSubtitle.requestIMDB to use the media title as the text    for the lookup if the video is being streamed- Change MainMenuActions.saveDownloadedSub to copy downloaded subtitles    from streamed files to "~/Movies"- Change OnlineSubtitle.getSubtitle to correct a failure to display the    OSD when using shooter.cn- Change OpenSubSubtitle.hash and ShooterSubtitle.hash to ensure file    is closed- Improve logging when obtaining subtitlesWith these changes subtitles can be downloaded and viewed for moviesstreamed from YouTube and from Dailymotion when using OpenSubtitles.org.  
>Fix  UI: Appearance setting is ignored, iina#3436If applied this commit will change AppDelegate.applicationDidFinishLoadingto set the appearance at the application level based on the IINApreference and establish an observer to watch the preference for changesand update the appearance as needed. The appearance can only be set atthe application level when running under macOS 10.14 and above. Whenrunning under earlier versions of macOS the IINA preference willcontinue to just be applied to the player windows.To minimize changes for this fix the existing code that sets theappearance at the windows level was not updated to only set theappearance when running under macOS 10.13 and below.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-08  
Contributor(s):  
xjbeta  
low-batt  
>DM port.  
>Fix IINA 1.2.0 crashes instantly (Big Sur), iina#3478This commit will change the method `SleepPreventer.preventSleep`to submit a task to the main DispatchQueue to display an alert if macOSreturns an error when IINA asks it to not put the display to sleep.This fixes a crash due to trying to display an alert using a thread other thanthe main thread.Logging has been added to log the failure macOS is returning.  
>Closes log the versions of dependencies, iina#3490This commit will:- Change AppDelegage.applicationWillFinishLaunching to log the IINA version,  FFmpeg version and the versions of FFmpeg libraries- Change AppDelegage.applicationDidFinishLaunching to log the mpv versionThe version of mpv is not logged in  applicationWillFinishLaunching becausempv does not provide a static method that returns the version. To obtainversion related information you must construct a mpv object, which has sideeffects. So the mpv version is logged in applicationDidFinishLaunching topreserve the existing order of initialization.  
>Fix constant CPU usage by Playlist Panel, iina#3162This commit will change the method PlaylistViewController.tableView tocheck if PlayerCore.refreshCachedVideoInfo was able to populatePlaybackInfo.cachedVideoDurationAndProgress and not submit a reload ofthe view if the cache is missing data.This commit also updates FFmpegController.probeVideoInfoForFile to logerrors when libavformat methods return an error code.This fixes an infinite table view reload loop that currently occurs whenrefreshCachedVideoInfo is unable to populate the cache.The infinite reload loop may be the cause of this issue:Excessive CPU consumption when opening the Playlist Panel, iina#3162  
>Fix app info missing copyright, iina#3470This commit will add the copyright to the app info window and update theabout window to display a copyright that reflects 2021 and uses the copyrightsymbol.  
>Fix screenshot crash with long video title, iina#3334This commit will:- Change the method  MPVController.handleEvent to raise an alert if    screenshot generation failed- Change the method  Utility.getLatestScreenshot to guard against an empty    screenshot directoryThis commit adds new text for the alert that will require localization.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-07  
Contributor(s):  
low-batt  
>HDR code cleanupAlso fix some memory leaks in FFmpegController  
>Fix unlabeled trailing closure build warnings, iina#3466This commit will eliminate Swift compiler build warnings due to backwardmatching of unabled trailing closure being deprecated as of Swift 5.3.The changes merely involve adding parameter labels to trailing closures incalls to `Just.get` and `Just.post`.  
>Fix many FileInfo objects leaked, iina#3445Fixes a retain cycle in the FileGroup.flatten method by replacing a recursiveclosure with a nested function. This eliminates a memory leak consisting of acollection of FileInfo objects representing the files contained in the directoryof the video being played.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-06  
Contributor(s):  
low-batt  
>Fix currently open filenames not syncing, iina#3159Change MainWindowController.windowWillOpen to set the window's title to"Window", the title a NSWindow has by default. If the title is not resetwhen a window is reused then the wrong title will be displayed in the"Window" menu.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-05  
Contributor(s):  
Collider LI  
>--wip--  
>Plugin: Add disableUI  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-04  
Contributor(s):  
Tianyi Shi  
xjbeta  
>add lrc to supportedFileExt[.sub]  
>Fix #3364.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2021-01  
Contributor(s):  
Anastasiy Safari  
xjbeta  
>Better HDR color space detection  
>Added HDR detection  
>Reset player.  
>Basic HDR support, using PQ curve  
>Correct thumbnail size  
>Basic HDR support, mpv now receives correct color space  
>Thumbnail size changing and HDR detection improvements  
>Basic HDR support, using PQ curve, consolidated changes  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-11  
Contributor(s):  
Collider LI  
xjbeta  
>Merge remote-tracking branch 'origin/develop' into danmaku-support  
>Add events, refine permissions  
>Fix some memory leaks when adding observers  
>URL scheme api for danmaku.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-10  
Contributor(s):  
Collider LI  
xjbeta  
>Plugin: Global controller  
>Plugin: Unload sidebar view gracefully  
>Fix merge.  
>Plugin: Sidebar  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-09  
Contributor(s):  
Collider LI  
>Plugin: fix memory leaks  
>Plugin: use JSManagedValue  
>Plugin: support playlist context menu  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-08  
Contributor(s):  
Collider LI  
>Plugin: menu updating mechanism  
>Plugin: Support installing from local package  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-07  
Contributor(s):  
Collider LI  
>Plugin: search online subtitles  
>Plugin: choose subtitle provider in preferences  
>Plugin: Fix existing memory leaks  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-06  
Contributor(s):  
xjbeta  
>Danmaku uuid.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-03  
Contributor(s):  
Collider LI  
Inflation  
Nate Weaver  
>Plugin: Support installing from GitHub  
>Plugin: Remember plugin order  
>Plugin: Basic structure for subtitle provider API  
>Plugin: Fix memory leak in hooks API  
>Change plug-in to plugin  
>Plugin: Normalize l10n keys  
>Rotate the thumbnails according to the display matrix  
>Plugin: Update playlist API  
>Preliminary scripting support  
>Plugin: Add uninstall and reveal in Finder  
>WIP: Rotate the view based on display rotation- TODO: fix image frame  
>Plugin: Add alert when duplicated identifiers detected  
>Plugin: Support updating from GitHub  
>Plugin: Fix memory leaks, add more polyfill  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-02  
Contributor(s):  
Collider LI  
Yuze Jiang  
>Plugin: Support removing event listeners, update menu API  
>Plugin: Add more eventsWill emit those window-related events after #2772 is merged  
>Plugin: Add playlist APIs  
>Plugin: Add tracks API  
>Plugin: Implement playlist API  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2020-01  
Contributor(s):  
xjbeta  
>Fix merge.  
>Bump version.  
>Bump verison, fix thread problem.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-10  
Contributor(s):  
xjbeta  
>isNetworkResource.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-08  
Contributor(s):  
Collider LI  
Yuze Jiang  
>Bug fix  
>+Plugin API: setting and getting enabled and state for a menu item  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-05  
Contributor(s):  
Yuze Jiang  
xjbeta  
>1.0.4 build 8.  
>Do not set values after mpv is destoryed  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-04  
Contributor(s):  
Yuze Jiang  
xjbeta  
>Refactoring logic  
>Refactor termination logicFixes #2396  
>Revert some changes  
>Refactor `togglePause`, provide resume and pause functionFix fast forward state not been reset when pausingCancel fast forward state when changing speed manually, #2390  
>Add PlaybackInfo.isPlaying, which is calculated from isPaused  
>Bump version to 1.0.3-Danmaku.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-03  
Contributor(s):  
Collider LI  
>Plugin: Add support for pref page  
>Plugin: Add utils  
>Plugin: add support tab in preferences  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2019-02  
Contributor(s):  
Collider LI  
xjbeta  
>Add missed "=".  
>Plugin: Support video-overlay  
>Bump version to v1.0.2-danmaku-build6.  
>Add directly option to iina-cli.  
>Plugin: allow communication between plugin and overlay  
>Update directly log.  
>Merge develop into danmaku-support  
>Bump version to v1.0.2-danmaku-build5.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2018-12  
Contributor(s):  
Collider LI  
xjbeta  
>Plugin: Add basic support for menu items  
>Fix dragging to start point.  
>Check the distance in mouseDragged.  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 


2018-09  
Contributor(s):  
Collider LI  
sidneys  
>Refactor event system  
>feat(save-youtube-playlist-items): extends the playlist disk writer, which now uses the Extended M3U format in order to preserve the titles of saved YouTube playlist items  
>feat(save-youtube-playlist-items): adds commentary to the playlist disk writer  
>fix(save-youtube-playlist-items): change string formatting strategy as per https://github.com/lhc70000/iina/pull/1959#pullrequestreview-152724715  
>Basic framework for JS plugin  
>Add plug-in tab in Preferences  
>fix(save-youtube-playlist-items): adds newline after M3U file header and track entry  
>Events, OSD, require for JS plugin  
- - - - - - - - - - - - - - - - - - - - - - - - - - - 

