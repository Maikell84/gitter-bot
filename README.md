# Simple Gitter-Bot

## Preparations

- You need a gitter API access-token. You can obtain one here: https://developer.gitter.im/apps
- You need a RoomId, where you want the bot to run. You can find the RoomId here: https://api.gitter.im/v1/rooms?access_token=GITTER-TOKEN
- For the gif-displaying functionality you need a giphy access-token: You can obtain one here:  https://giphy.com
- Put the Access-Tokens in environment-Variables by starting the script with parameters, or by editing your system environement-variables. E.g. in your ~/.bashrc file:


      export GITTER_TOKEN='your gitter token'
      export GITTER_ROOM_ID='your gitter room id'
      export GIPHY_API_KEY='your giphy token'

This bot can also listen to multiple rooms simultaneously. Just enter the room ids in the array `room_ids` in the initialize method.

## Installation

    bundle install

## Usage

Start the software with:

    ruby gitter_bot.rb

Bot will listen to following commands, in the gitter-room that you have specified:

    tell a joke
    gif topic
    activate time service # Displays a clock-emoji every 30 min
    deactivate time service # Stops displaying a clock-emoji every 30 min


## Contributing

1. Fork the repository
2. Create a branch (`git checkout -b new-branch`)
3. Commit your changes (`git commit -am 'Add great new thing'`)
4. Push to the branch (`git push origin new-branch`)
5. Create new Pull Request
