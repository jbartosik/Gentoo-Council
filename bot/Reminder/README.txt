This plugin act this way:
 0. Set last_reminder_time to something long time ago.
 1. Sleep for some time.
 2. Fetch from given url.
 3. Parse JSON, assign result to ping_data. Expect ping_data to be dictionary.
 4. If the ping_data is empty go to 1.
 5. If last_reminder_time >= ping_data['remind_time'] go to 1.
 6. Make sure ping_data['users'] is an array
 7. Ping all nicks in ping_data['users']
 8. Go to 1.
