# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Database Setup
```bash
rake db:create
rake db:migrate
rake db:seed  # Loads domain tables and test data
```

### Running the Application
```bash
rails server
```

### Testing
```bash
rails test                    # Run all tests
rails test test/models/       # Run model tests only
rails test test/controllers/  # Run controller tests only
```

### Code Quality
```bash
bundle exec rubocop           # Run RuboCop linter
bundle exec rubocop -A        # Auto-correct RuboCop offenses
```

### Rails Console
```bash
rails console
# Execute the scheduler algorithm: SchedulerService.call
```

## Application Architecture

This is a Ruby on Rails 5.2.8 application (Ruby 2.6.3) that implements a logistics route scheduling system for drivers and vehicles.

### Core Domain Models

The application manages transportation logistics with these key entities:

- **Route**: Transportation routes with time windows, load requirements, cities, and stops
- **Driver**: Drivers with city coverage areas and maximum stop limits
- **Vehicle**: Vehicles with capacity and load type constraints  
- **LoadType**: Categories of cargo that can be transported

### Key Business Logic

**SchedulerService** (`app/services/scheduler_service.rb`): Core algorithm that assigns available drivers and vehicles to unassigned routes based on:
- Driver city coverage matching route cities
- Driver maximum stops capability
- Vehicle load type and capacity constraints
- Time window availability (routes finished vs. unfinished)

The algorithm can be executed via:
- Rails console: `SchedulerService.call`
- Web interface: "Asignar rutas" button (`/visitors/assign`)

### Database Schema

Uses PostgreSQL with array fields for cities. Key relationships:
- Routes belong to load_types and can be assigned to drivers/vehicles
- Drivers can own vehicles and be assigned to multiple routes
- Vehicles belong to load_types and can be assigned to drivers

### Route Scopes

Important Active Record scopes in Route model:
- `unassigned`: Routes without driver/vehicle for today
- `finished`: Completed assigned routes for today  
- `unfinished`: Active assigned routes for today
- `assigned_today`: Routes assigned to specific vehicle/driver today

### Frontend

Simple Rails application using:
- HAML templates
- Bootstrap 4.3.1 for styling
- jQuery for JavaScript
- Visitors controller serves main interface displaying all routes

### Testing

Uses standard Rails testing framework with fixtures for all models. Test files available for all core models.