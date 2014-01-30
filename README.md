# Candela #

Application for managing activists (volunteers) and related information in a wide organization.

This application is in process of refactoring from a previous version. There will be a lot of updates in the next weeks...

## Installation ##

1. There are three files in config folder that you must rename (remove .sample) and change to suit your own settings: database.yml, mailer.yml and application_settings.yml

1. Put your own seeding data in seeds.rb file. The list of needed seeding data is in our ToDo list...

1. Build your own mailing templates. They are located in folders app/views/application_mailer and app/mail_templates

1. Build your own customizable views. They are located in folders app/views/customizable_views

1. Run rebuild task and run the server
    ```
    rake db:rebuild
    ```

## Project info ##

The project is hosted on Github: https://github.com/amnesty/candela , where your contributions, forkings, comments, issues and feedback are welcomed.

### License ###

Candela. Application for managing activists (volunteers) and related information in a wide organization.
Copyright (C) 2013 Amnesty International (originally developed by Gnoxys <http://gnoxys.net> and Dabne <http://dabne.net>).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program (see LICENSE.txt). If not, see <http://www.gnu.org/licenses/>.
