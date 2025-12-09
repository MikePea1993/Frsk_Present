Config = {}

-- Debug mode
Config.Debug = false

-- Mail Stamp Image URL (appears on the tag)
Config.MailStamp = "https://i.ibb.co/PZBjD2mY/Chat-GPT-Image-Nov-9-2025-03-21-39-PM-removebg-preview.png"

-- Item names (must match your database items)
Config.Items = {
    EmptyPresent = "empty_present",
    ChristmasPresent = "christmas_present"
}

-- Notification settings (Vorp)
Config.Notifications = {
    PresentCreated = "You have wrapped a Christmas present!",
    PresentOpened = "You opened a Christmas present!",
    NoItemSelected = "You must select an item to put in the present!",
    MissingFields = "Please fill in all fields on the tag!",
    ItemNotFound = "The item in this present could not be found!"
}