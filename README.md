# Home Budget API

REST API for tracking personal expenses and budget.

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Setup](#setup)
5. [Running the App](#running-the-app)
6. [API Documentation and Testing](#api-documentation)


## Introduction

This API is designed to help users track their expenses and manage their budgets efficiently. Users can create categories, add expenses, filter expenses, and see their current budget status.

## Features

- User authentication (JWT-based using Devise)
- Expense and category CRUD
- Filtering expenses by date, price range, and category
- Predefined budget for each user
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
- Bundler

### Steps

- Clone this repository.
- Download secrets from Lastpass item named **HB Secrets** stored in **Shared-Development** folder and extract files to config folder inside your local repository.
- Setup database with `rails db:create` followed by `rails db:migrate`

## Running the App

- Start server with `bundle exec rails s`
- Default port currently set to 3001.

## API Documentation

* Start rails server and Documentation is available on [Swagger](http://localhost:3001/api-docs/index.html).
* To test all endpoints, after login copy bearer value and paste it in Authorize function at the top of Swagger documentation page.
* Hope you have fun using Home Budget API!
