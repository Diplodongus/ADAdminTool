# ADAdminTool

ADAdminTool is a PowerShell script for managing Active Directory (AD) users and groups. It allows you to perform common AD tasks, such as creating and modifying users and groups, without the need for manual intervention in the AD management console.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

- ADAdminTool requires PowerShell 3.0 or later to be installed on your machine.
- You will also need to have administrative access to an Active Directory domain.

### Installation

1. Download the latest version of the ADAdminTool script from the [releases](https://github.com/Diplodongus/ADAdminTool) page.
2. Save the script to a directory on your local machine.

### Usage

To use ADAdminTool, open a PowerShell prompt and navigate to the directory where ADAdminTool is saved. Then, run the following command:

The script will prompt you for the action you want to perform and the required parameters. For example, to create a new user, you would run the script and select the "Create User" option and enter the required information such as username, password, first name and last name.

### Available actions
Create User: Creates a new user in the Active Directory.
Modify User: Modifies an existing user in the Active Directory.
Delete User: Deletes an existing user from the Active Directory.
Create Group: Creates a new group in the Active Directory.
Modify Group: Modifies an existing group in the Active Directory.
Delete Group: Deletes an existing group from the Active Directory.

### Built With
PowerShell - The scripting language used

### Authors
Diplodongus - Initial work - Diplodongus

### License
This project is licensed under the MIT License - see the LICENSE.md file for details

### Acknowledgments
Hat tip to anyone whose code was used
Inspiration
etc

```powershell
.\ADAdminTool.ps1

