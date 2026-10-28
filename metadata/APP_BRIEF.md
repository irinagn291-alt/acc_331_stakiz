<!-- gf-brief source=3431f19419196a498d3d81599f425b5282b2c59dbcff067df41e9cd3988098c9 written=2026-10-23T09:06:11+03:00 -->
# Stakiz
## What it is
Stakiz is a household pet-chore board. Each pet has a collar code and a set of chores for the day, shown as posts on one column. You scan a collar, then seat that pet’s open chores until every active chore is seated and the day clips shut. It is for someone keeping daily care for the animals in one home.

## Launch and onboarding
A cold launch on a phone or tablet with no saved household opens a full-screen intro before the day board. There is no separate splash copy. The intro has three pages, page dots, "Skip" at the top, and a bottom button.

1. Title "Collar chores". Body "Each pet keeps today's chores on one paper column." Button "Next". "Skip" ends the intro.
2. Title "Scan, then snap". Body "Read a collar, then drag the chore onto its post." Button "Next". "Skip" ends the intro.
3. Title "Clip the day". Body "When every chore is seated, the day clips shut." Button "Continue". "Skip" also ends the intro.

"Continue" or "Skip" leaves the intro and opens the day board. The intro does not return on later launches unless "Show intro again" is used in Settings.

## Screens
The app has one home board. Other screens open as full-screen covers from that board. There is no tab bar.

### Today
The home board has no navigation-bar title. Across the top, five controls open covers: "Pets", "Chores", "Log", "Goals", "Settings".

Under them, a large headline and a status line change with the day:

- No pets or no active chores: headline "No chores yet". Status "Household empty. Add a pet."
- Chores exist and no collar has been read today: headline "Scan a collar". Status "Scan a collar."
- A collar has been read and a chore is open: headline "Snap " plus that chore’s name. Status is that chore’s name plus " is open. Drag it onto the glowing post." If that pet has nothing left to seat, the status is "Scan the other collar to arm its chores."
- Every active chore is seated: headline "Day clipped". Status "Day clipped."

Other status lines appear after an action: "Collar read. Empty posts are armed.", "Seated.", "Day clipped.", "Wrong post. It bounced back.", "Scan a collar, then drag the chore.", "Missed the post. Try again.", "Day clipped. Undo the last seat, then scan.", "Day clipped. Undo the last seat, then drag.", "That post already holds a chore.", "Snap failed. Try again.", "Scan failed. Try again.", "Add a pet before scanning.", a chore name plus " is marked on today. Drag it onto its post.", "Last seat lifted. Drag is open.", "No seat to undo.", "Pet added.", "Chore added.", "Name missing. Type a pet name.", "Name missing. Type a chore name.", "Pick a pet for this chore.", "Household cleared.", "Demo household restored. Snap the next chore." (simulator only).

If saving fails, a card shows "Save failed. Try again." and "Retry". If a saved household cannot be read, the card shows "Household file was unreadable. Start fresh or retry." and "Retry". If a backup is used, the card shows "Last save was repaired from the backup." and "Retry".

When there are no active chores, the board shows "No chores yet.", "Add a pet and a chore.", and "Add a pet", which opens Pets.

When chores exist, the board shows "Today's posts". The glowing post shows the pet name, a middle dot, the time window, the chore name, and "Glowing post". Tapping it seats that chore. A seated row shows the pet name, the chore name, and "Seated". An armed open row shows the pet, the window, "Snap " plus the chore name, and "Open"; tapping it seats that chore. A held row shows the pet, the window, the chore name, and "Show"; tapping it marks that chore on today and sets the status to the chore name plus " is marked on today. Drag it onto its post."

A tray sits under the posts. Its caption is one of: "Add a pet, then a chore.", "Scan a collar before you drag.", "Drag the open chore onto the glowing post above.", or "Clipped. Undo the last seat to reopen." Chore chips in the tray can be dragged onto a matching post. A matching post keeps the chore. A miss springs it back. Dragging before a collar read does not seat the chore. Dragging is ignored once the day is clipped or the board is empty. A large button "Snap " plus the glowing chore’s name also seats that chore.

"Collars" offers the camera. Before permission, the button is "Continue" and the line is "Reads a collar code on this device." After the camera is allowed, a live view reads a QR code and closes the live view. If the camera is denied, the copy is "Camera is off. Open Settings to change it." and the button is "Open Settings". Known pets appear as buttons labeled with the pet’s name; each one counts as a scan of that pet’s collar code.

"Scan collar" opens the scan cover. It is disabled when the day is clipped. "Undo seat" lifts the last seated chore for today and, if the day was clipped, reopens it. It is disabled when nothing is seated today. When the day is clipped, "Undo seat" is the stronger of the two buttons; otherwise "Scan collar" is the stronger one while the day is waiting for a first scan.

"Clipped days" shows the streak count and today’s date number.

### Pets
Title "Pets". "Close" returns to Today. Empty state: "No pets yet." and "Add a pet and a chore." The field placeholder is "Pet name". "Add pet" is disabled until the name has a non-space character. "Done" dismisses the keyboard. Adding a pet also creates a collar code from the name, shown under the pet. "Print collar sheet" opens a share sheet whose control reads "Share collar sheet" and whose preview title is "Collar sheet". The sheet image shows the pet name and the collar code as a QR code.

### Chores
Title "Chores". "Close" returns to Today. Empty state: "No chores yet." and "Add a pet and a chore." If there is no pet, the form says "Add a pet first." and does not offer "Add chore". Otherwise a "Pet" picker lists pet names, a "Chore name" field, and a "Time window" field that starts as "Morning". "Add chore" is disabled until the chore name has a non-space character and a pet is selected. An empty time window is stored as "Today". Each saved chore shows an editable "Chore name", the pet name, the time window, and a switch "Active today". "Done" dismisses the keyboard. Inactive chores leave today’s posts.

### Log
Title "Log". "Close" returns to Today. Empty state: "No seats this week.", "Snap a chore on today.", and "Show today", which closes the log. With history, the page is titled "Week" in the body. A grid header reads "Chore" and seven day-of-month numbers ending today. Each active chore has a row; a filled check means seated that day and an open circle means open. "Misses" lists wrong posts and early drags as a date number, then "Wrong post" or "Early drag", then the pet name and chore name. Collar reads in that list read "Collar", seats read "Seated", and clipped days read "Clipped". If there are no misses, the line is "No wrong posts or early drags." A share control’s spoken label is "Export week". It shares seven days of chores as seated or bare.

### Goals
Title "Goals". "Close" returns to Today. "Streak" shows the count of consecutive clipped days and the line "Consecutive clipped days." "Today" shows a count " of " another count plus " seated", with a bar. "Yesterday" says either "Today is still open. Seat the remaining chores to grow the run." when the streak is zero, or "The run is live. Keep every active chore seated." The bottom button is "Snap " plus the open chore’s name, or "Show today" when nothing is armed. It closes Goals.

### Scan collar
Title "Scan collar". Large heading "Scan a collar", then the same status line as Today. "Close" returns to Today. If the camera is not yet allowed: "Camera waits until you continue." and "Continue", which asks for the camera. If it is allowed, a live view reads one QR code, treats it as a collar code, and closes. If it is off: "Camera is off. Open Settings to change it." and "Open Settings". "Known collars" lists buttons named with the pet name, a space, and the collar code. Tapping one scans that code and closes. A scan is refused while the day is clipped, when there is no pet, or when the code does not match a saved collar.

### Settings
Title "Settings". "Close" returns to Today. "Show intro again" closes Settings and shows the three-page intro. "Reset household" asks "Reset household?" with "Reset all data" and "Cancel". "Reset all data" clears pets, chores, seats, and the streak, and the status becomes "Household cleared." "Contact support" opens the support page. Section "Camera" says "Collar scan uses the camera. If it is off, use Open Settings." and offers "Open Settings". On the simulator only, "Restore demo household" puts the sample household back.

## Features
- Intro pages "Collar chores", "Scan, then snap", and "Clip the day".
- A day column of posts for each active chore, with "Glowing post", "Open", "Show", and "Seated".
- Collar scan from a QR code, or a tap on a known pet, which arms that pet’s empty posts.
- Drag a chore from the tray onto its post, or tap "Snap " plus the chore name, to seat it.
- A wrong post bounces the chore back. A drag before any collar read is kept as an early drag. A miss does not seat the chore.
- When every active chore is seated, the day clips and the streak of "Clipped days" can grow.
- "Undo seat" lifts the last seat for today and reopens a clipped day.
- Pets, collar codes, and a printable "Collar sheet".
- Chores with a pet, a name, a time window, and "Active today".
- A seven-day "Log" with "Misses" and "Export week".
- "Goals" with today’s seated count and the streak.
- "Show intro again", "Reset household", "Contact support", and camera "Open Settings".

## Behaviours that can look like bugs
- "Add pet" stays disabled until "Pet name" contains something other than spaces. Type a name.
- "Add chore" stays disabled until "Chore name" contains something other than spaces and a pet is selected. If the line "Add a pet first." is showing, add a pet on Pets, then return.
- With no active chores, Today shows "No chores yet." and "Add a pet and a chore." Use "Add a pet".
- "Scan collar" is disabled and the tray says "Clipped. Undo the last seat to reopen." after the day clips. Tap "Undo seat", then scan. Status if you still try: "Day clipped. Undo the last seat, then scan." or "Day clipped. Undo the last seat, then drag."
- "Undo seat" is disabled when nothing is seated today. Seat a chore first. If it is tapped with nothing to lift, the status is "No seat to undo."
- Dragging before a collar read does not seat the chore. Status: "Scan a collar, then drag the chore." Scan, then drag.
- A chore dropped on another chore’s post bounces back. Status: "Wrong post. It bounced back." Drop it on its own glowing post.
- A drop that misses the post does not seat it. Status: "Missed the post. Try again."
- A post that already holds a chore refuses another. Status: "That post already holds a chore."
- An unknown QR code does not arm a pet. Status: "Scan failed. Try again." Use a code shown under that pet, or the pet’s button under "Known collars".
- Scanning with no pets shows "Add a pet before scanning."
- Turning "Active today" off removes that chore from today’s posts. The day can clip from the chores that remain. Turn it back on to include it again.
- At the next calendar day the posts are open again. Yesterday’s seats stay in "Log". The streak counts only consecutive clipped days and stops at the first day that is not fully seated.
- "Show" on a held post only marks it. It does not seat it. The status says the chore " is marked on today. Drag it onto its post."
- After one pet’s chores are seated, the headline becomes "Scan the other collar" until the next collar is read.
- "Retry" reloads after "Save failed. Try again." or "Household file was unreadable. Start fresh or retry."

## Starter content and resume
On a device, none. The first launch is the intro, then an empty board.

On the simulator, a sample household is already filled after the intro is skipped by that sample: pets "Mira" and "Pip", collar codes "CHL-MIRA" and "CHL-PIP", chores "Feed" (Morning), "Walk" (Afternoon), and "Brush" (Evening) for Mira, and "Water" (Night) for Pip. Yesterday is fully seated and clipped. Today, Mira’s collar is already read and "Feed" is seated, so the board is waiting to snap "Walk". The log also has an early drag on "Walk" from two days ago and a wrong post on "Walk" today. "Restore demo household" in Settings puts that sample back. It is not on a device.

Unfinished work resumes. Pets, chores, today’s seats, and the streak stay on the device and return on the next launch. "Undo seat" can reopen today. A new calendar day starts a fresh open column.

## Permissions
Camera, for reading a collar QR code. It is asked only after "Continue" on Today under "Collars", or "Continue" on "Scan collar". The usage description is "Checklead reads the code on a pet collar tag so today's chores lock onto that animal." If the person says no, the app shows "Camera is off. Open Settings to change it." and "Open Settings". It does not ask again in the app.

## Absent
Login or accounts, in-app purchase, ads, analytics, a public user-generated content feed, an account-deletion flow, and an App Tracking Transparency prompt. Names typed for pets and chores stay in the household on this device. "Reset all data" clears that household. It is not an account deletion.

## Data and support
The household stays on this device. "Contact support" in Settings opens the support page.

## Scanning and health
The app scans QR codes. It expects a collar code that matches a pet already in the household, including codes printed on "Collar sheet" and the buttons under "Known collars". A code that does not match shows "Scan failed. Try again."

None for health, medical, or product-health information.

## Platform
The on-screen language is English. Counts and the date number follow the device’s number format. There is no region lock. The interface is light. iPhone uses portrait and both landscapes. iPad uses portrait, upside-down portrait, and both landscapes, full screen. iPhone and iPad. Minimum iOS 17.0. The name under the icon is "Stakiz".

## Category
Lifestyle
