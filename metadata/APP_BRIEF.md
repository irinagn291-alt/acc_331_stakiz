<!-- gf-brief source=21a1a7130ba16a09af859a01762c26b05cb518b9cf43e4a30fc2774c39a2fe78 written=2026-10-22T02:26:55+03:00 -->
# Stakiz
## What it is
Stakiz is a household pet-chore board. Each pet has a collar code and a set of chores for the day. You scan that collar, then seat each open chore on its post. When every active chore is seated, the day clips shut and the streak of clipped days can grow. It is for someone keeping daily care for the animals in one home.
## Launch and onboarding
A cold launch on a new install opens a three-page introduction before the day board. Page dots show which page you are on.

1. Title "Collar chores". Body "Each pet keeps today's chores on one paper column."
2. Title "Scan, then snap". Body "Read a collar, then drag the chore onto its post."
3. Title "Clip the day". Body "When every chore is seated, the day clips shut."

"Skip" on every page finishes the introduction and opens the day board. "Next" advances from page 1 to page 2 and from page 2 to page 3. On page 3 the same button reads "Continue" and opens the day board. After that, a later launch opens the day board directly and keeps the household you already entered.

The day board has no tab bar. A horizontal row of controls sits at the top: "Pets", "Chores", "Log", "Goals", and "Settings". Each opens a full-screen page. "Close" on those pages returns to the day board.
## Screens
### Day board
There is no navigation title. The large line changes with the day:

- "No chores yet" when there is no pet or no active chore. Under it: "Household empty. Add a pet." The tray caption reads "Add a pet, then a chore."
- "Scan a collar" when chores exist and no collar has been read today. Under it: "Scan a collar." The tray caption reads "Scan a collar before you drag."
- "Snap" plus the open chore name after that pet's collar is read. Under it, the chore name plus " is open. Drag it onto the glowing post." The tray caption reads "Drag the open chore onto the glowing post above."
- "Scan the other collar" when the read pet's chores are seated and another pet still has open chores. Under it: "Scan the other collar to arm its chores."
- "Day clipped" when every active chore is seated. Under it: "Day clipped." The tray caption reads "Clipped. Undo the last seat to reopen."

Other lines that replace that status after an action: "Collar read. Empty posts are armed." "Seated." "Day clipped." "Wrong post. It bounced back." "Scan a collar, then drag the chore." "Missed the post. Try again." "Day clipped. Undo the last seat, then scan." "Day clipped. Undo the last seat, then drag." "That post already holds a chore." "Snap failed. Try again." "Scan failed. Try again." "Add a pet before scanning." "Last seat lifted. Drag is open." "No seat to undo." "Pet added." "Chore added." "Name missing. Type a pet name." "Name missing. Type a chore name." "Pick a pet for this chore." "Household cleared." A chore name plus " is marked on today. Drag it onto its post."

If the saved household cannot be read, a card shows "Household file was unreadable. Start fresh or retry." or "Last save was repaired from the backup." or "Save failed. Try again." "Retry" tries to load the household again.

Empty board, before any pet and chore: an illustration, "No chores yet.", "Add a pet and a chore.", and "Add a pet", which opens Pets. The tray and collar tools are not on this empty board.

Once there is at least one active chore, the board shows "Today's posts", then the tray, then a "Snap" button for the glowing chore, then "Collars", then "Scan collar" and "Undo seat", then "Clipped days".

"Today's posts" lists each active chore. A seated chore shows the pet name, the chore name, and "Seated". The glowing open chore shows the pet name, a middle dot, and the time window, then the chore name, then "Glowing post". Tapping it seats that chore. Another open chore for the same collar shows the pet, window, "Snap" plus the chore name, and "Open". Tapping it seats that chore. A chore whose collar has not been read shows the pet, window, the chore name, and "Show". Tapping "Show" marks that chore on today and sets the status to the chore name plus " is marked on today. Drag it onto its post."

Under the posts, "Snap" plus the glowing chore name seats that chore on its post.

The tray is a row of chips, one per active chore that is not yet seated. Each chip is labeled with the chore name. Drag a chip upward onto the matching post. A match seats it. A miss springs it home. Chips do not move when the household is empty or the day is clipped. After one collar is read, only that pet's open chores can be dragged.

"Collars" lists a button for each pet that has a collar code. The button title is the pet name. Tapping it counts as reading that collar, with no camera. Before the camera is on, "Continue" is shown with "Reads a collar code on this device." "Continue" asks for the camera and, if allowed, shows the camera in that strip. If the camera is off, the strip says "Camera is off. Open Settings to change it." and "Open Settings" opens the system Settings app.

"Scan collar" opens the scan page. It is disabled while the day is clipped. It is the filled button while the day is waiting for a collar, and the quieter button after a collar has been read. "Undo seat" lifts the last chore seated today and reopens the day. It is disabled until something is seated. It is the filled button while the day is clipped.

"Clipped days" shows the streak as a number, and the date as an eight-digit year, month, and day with no separators.

### Pets
Title "Pets". "Close" returns to the day board. While typing, "Done" dismisses the keyboard.

Empty: an illustration, "No pets yet.", "Add a pet and a chore.", a field labeled "Pet name", and "Add pet". "Add pet" stays disabled until the name has a letter or number in it. Adding a pet clears the field, shows "Pet added.", and gives that pet a collar code built from the name.

With pets, the same name field and "Add pet" sit above the list. Each row shows the pet name, the collar code, and "Print collar sheet". "Print collar sheet" opens a sheet titled in the share preview as "Collar sheet", with "Share collar sheet". The sheet image shows the pet name, a square code, and the same code as text. Sharing uses the system share sheet.

### Chores
Title "Chores". "Close" returns. "Done" dismisses the keyboard.

Empty: an illustration, "No chores yet.", "Add a pet and a chore." If there is no pet, the form says "Add a pet first." and there is no add button. With a pet, the form has a "Pet" picker, a field labeled "Chore name", a field labeled "Time window" that starts as "Morning", and "Add chore". "Add chore" stays disabled until a chore name is typed and a pet is chosen. A blank time window is stored as "Today". Adding shows "Chore added."

Each existing chore shows an editable "Chore name", the pet name, the time window, and "Active today". Turning "Active today" off removes that chore from today's posts and tray. Turning it on puts it back. Clearing the name and leaving it blank does not save the blank name.

### Log
Title "Log". "Close" returns. The share icon is labeled "Export week" and opens the system share sheet with the week's seats and misses.

Empty, before any seat or miss is recorded: an illustration, "No seats this week.", "Snap a chore on today.", and "Show today", which returns to the day board.

With history: "Week", then a grid headed "Chore". Seven columns show the day-of-month numbers for the last seven days, ending today. Each active chore is a row. A filled mark means seated that day. An empty circle means open. Under that, "Misses". If there are none: "No wrong posts or early drags." A miss line is the date, then "Wrong post" or "Early drag", then the pet name and the chore name.

### Goals
Title "Goals". "Close" returns. "Streak" and the streak number, then "Consecutive clipped days." "Today" shows a count such as "0 of 2 seated" and a bar for how many of today's chores are seated. "Yesterday" shows either "Today is still open. Seat the remaining chores to grow the run." when the streak is zero, or "The run is live. Keep every active chore seated." when the streak is at least one. The bottom button reads "Snap" plus the glowing chore name, or "Show today" when nothing is glowing. Either button returns to the day board.

### Scan collar
Title "Scan collar". "Close" returns. The large line is "Scan a collar". Under it is the same status line as the day board. "Known collars" lists one button per pet, titled with the pet name and the collar code. Tapping one reads that collar and closes the page.

If the camera is not yet allowed: "Camera waits until you continue." and "Continue". "Continue" asks for the camera. If allowed, the camera fills the plate and reads a square code. A successful read closes the page. If the camera was refused: "Camera is off. Open Settings to change it." and "Open Settings".

### Settings
Title "Settings". "Close" returns.

"Show intro again" closes Settings and shows the three introduction pages. Finishing them returns to the day board and does not erase pets or chores.

"Reset household" asks "Reset household?" with "Reset all data" and "Cancel". "Reset all data" clears pets, chores, collars, the log, and the streak, and the status becomes "Household cleared." The day board then shows the empty state. The introduction does not return by itself.

"Contact support" opens the support page.

Section "Camera": "Collar scan uses the camera. If it is off, use Open Settings." and "Open Settings".
## Features
- Introduction pages "Collar chores", "Scan, then snap", and "Clip the day", with "Skip", "Next", and "Continue".
- A day board of "Today's posts" for each active chore, marked "Glowing post", "Open", "Show", or "Seated".
- A tray of chore chips you drag onto the matching post. A miss springs the chip home.
- "Snap" plus the chore name, which seats that chore without a drag.
- Collar codes printed from "Print collar sheet", and "Known collars" you can tap instead of using the camera.
- "Scan collar" reads a square code on a collar.
- "Undo seat" lifts the last chore seated today and reopens a clipped day.
- "Clipped days" counts consecutive days that clipped shut.
- "Pets" with "Pet name" and "Add pet".
- "Chores" with "Pet", "Chore name", "Time window", "Add chore", and "Active today".
- "Log" for the last seven days, "Misses", and "Export week".
- "Goals" with "Streak", "Today", and "Yesterday".
- "Settings" with "Show intro again", "Reset household", "Contact support", and "Open Settings".
- The household remains on this device and is still there the next time the app opens. A new calendar day starts a new open day. Yesterday's seats stay in the log.
## Behaviours that can look like bugs
- "Add pet" does nothing until "Pet name" is filled in. Type a name, then tap "Add pet".
- "Add chore" does nothing until "Chore name" is filled in and a pet is chosen. With no pets, the form only says "Add a pet first." Add a pet, then return to Chores.
- The day board stays on "No chores yet." and "Add a pet and a chore." until there is a pet and at least one active chore. "Add a pet" opens Pets. Then add a chore under "Chores".
- Chips sit still and the caption says "Scan a collar before you drag." until a collar is read. Tap the pet under "Collars", or "Scan collar", then drag.
- Dragging before any collar read does not seat the chore. The status becomes "Scan a collar, then drag the chore." That drag is kept as an "Early drag" under "Misses".
- Dropping a chore on the wrong post does not seat it. The chip springs home and the status becomes "Wrong post. It bounced back." That miss is listed under "Misses" as "Wrong post".
- A drop that misses the post says "Missed the post. Try again." and the chip returns.
- After one pet's collar is read, the other pet's chips do not drag. The headline becomes "Scan the other collar". Scan or tap that pet's collar.
- When every active chore is seated, the headline is "Day clipped", "Scan collar" is disabled, and chips do not drag. The status may say "Day clipped. Undo the last seat, then scan." or "Day clipped. Undo the last seat, then drag." Tap "Undo seat" to lift the last seat. "Undo seat" itself is disabled while nothing is seated. Tapping it with nothing to lift says "No seat to undo."
- "Show" on a chore whose collar is unread does not seat it. It only marks it. Scan that collar, then snap or drag.
- Turning "Active today" off makes that chore vanish from today's posts and from the tray. Turn "Active today" back on to restore it.
- An unknown square code does not add a pet. The status becomes "Scan failed. Try again." Use the code printed for a pet you already added, or tap that pet under "Known collars".
- Scanning with no pet says "Add a pet before scanning."
- "Reset all data" looks like the app forgot the household. It is the confirm on "Reset household". Add pets and chores again.
- If saving fails, "Save failed. Try again." stays on screen with "Retry". If a damaged save was repaired, the card says "Last save was repaired from the backup." If it cannot be read, it says "Household file was unreadable. Start fresh or retry."
- The log stays on "No seats this week." until a chore is seated or a miss is recorded. "Show today" returns to the board. Seat a chore, then open "Log" again.
- Goals can say "0 of 0 seated" while the board is empty. Add a pet and a chore first.
- "Show intro again" plays the three pages again and then returns. It does not clear the household.
## Starter content and resume
None. A new install has no sample pets or chores. Unfinished chores stay on this device and are still open the next time the app is opened, until the calendar day changes. A new day starts open again. Seats from earlier days remain in "Log". "Undo seat" only lifts a seat from today.
## Permissions
Camera. It is asked only after you tap "Continue" on the day board under "Collars", or "Continue" on "Scan collar". The usage description is "Stakiz reads the code on a pet collar tag so today's chores lock onto that animal." If you refuse, the app shows "Camera is off. Open Settings to change it." and "Open Settings". You can still tap a known collar with no camera.
## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with other people, an account deletion flow, and an App Tracking Transparency prompt. "Reset household" only clears the household on this device. "Export week" and "Share collar sheet" use the system share sheet.
## Data and support
Pets, chores, collar codes, seats, misses, and the streak stay on this device. Collar reading happens on this device. "Contact support" is in Settings and opens the support page.
## Scanning and health
The camera reads a square code on a pet collar. It expects the code printed for a pet already in "Pets". That code is shown under the pet name and on the collar sheet. A matching code arms that pet's open chores. Any other code shows "Scan failed. Try again." Known collars can be chosen by tapping the pet name, with no camera. Health, medical, and product-health information: none.
## Platform
The app follows the device calendar and the device's number formatting for the streak and for day numbers in the log. Dates on the board are an eight-digit year, month, and day. The appearance is light. It runs on iPhone and iPad. iPhone can be portrait or either landscape. iPad is portrait. It fills the screen. The minimum iPhone and iPad system is iOS 17.0. A Watch app is included and shows a single static page, "Snap Walk", the figure "1", and "Drag the open chore onto its post." It has no buttons. Its minimum system is watchOS 26.0.
## Category
Lifestyle
