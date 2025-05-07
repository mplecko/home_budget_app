# Home Budget API

REST API for tracking personal expenses and budget.

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Setup](#setup)
5. [API Documentation](#api-documentation)
6. [RSpec Testing](#rspec-testing)

## Introduction

This API is designed to help users track their expenses and manage their budgets efficiently. Users can create categories, add expenses, filter expenses, and see their current budget status.

## Features

- User authentication (JWT-based using Devise)
- Expense and category CRUD
- Filtering expenses by date, price range, and category
- Predefined budget for each user
- Changeable maximum budget
- API documentation with Swagger
- RSpec for testing

## Tech Stack

- **Backend**: Ruby on Rails
- **Database**: PostgreSQL
- **Authentication**: Devise with JWT
- **API Documentation**: Swagger (using Rswag)
- **Testing**: RSpec

## Setup

### Prerequisites

Ensure you have the following installed:

- Ruby 3.2.1
- Rails 7.0.8
- PostgreSQL
- Docker
- Bundler

### Steps

- Clone this repository.
- Download secrets from Lastpass item named **HB Secrets** stored in **Shared-Development** folder and extract files to config folder inside your local repository.
- Run docker image and start container with `docker-compose up --build`
- When running application first time open separate terminal tab to create and migrate database using commands `docker-compose run web rake db:create` followed by `docker-compose run web rake db:migrate`
- Default local port is set to 3000.

## API Documentation

- Start rails server and Documentation is available on [Swagger](http://localhost:3000/api-docs/index.html).
- To test all endpoints, after login copy bearer value and paste it in Authorize function at the top of Swagger documentation page.
- Hope you have fun using Home Budget API!

## RSpec Testing

- All models and controllers are covered with RSpec tests.
- Run `rspec` command ub terminal to execute tests.
