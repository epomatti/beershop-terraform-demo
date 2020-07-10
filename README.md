# Beer Shop

A demo project to showcase Terraform features on top of Azure Cloud.

The demo is composed of three main modules:

- [**App**](/app) - A Dotnet MVC for user interaction where the user is able to push orders to a queue.
- [**Functions**](/functions) - The backend for the application that pulls and processes messages in the queue.
- [**Infrastructure**](/infrastructure) - The actual Terraform code that creates all the required resources.

Each module is documented separetely.

The following diagram shows all the resources provisioned with Terraform, plus an ACR for Docker images.

<img src="_docs/demo.png" width="500"> </img>