# Candela #

Application for managing activists (volunteers) and related information in a wide organization.

This application is in process of refactoring from a previous version. There will be a lot of updates in the next weeks...

## Installation ##

1. There are three files in config folder that you must rename (remove .sample) and change to suit your own settings: database.yml, mailer.yml and application_settings.yml

1. Put your own seeding data in seeds.rb file. The list of needed seeding data is in our ToDo list...

1. Build your own mailing templates. They are located in folders app/views/application_mailer and app/mail_templates

1. Run rebuild task and run the server
    ```
    rake db:rebuild
    ```

## Project info ##

The project is hosted on Github: https://github.com/amnesty/candela , where your contributions, forkings, comments, issues and feedback are welcomed.

### License ###

See LICENSE.txt file.



