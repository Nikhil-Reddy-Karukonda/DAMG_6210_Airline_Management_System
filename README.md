# 🛠 DB Design for an Airline Management System ✈️

## 🌐 Introduction

An airline management system is a software application enabling efficient airline operations management. It includes features such as flight scheduling, ticket reservations, cancellations, and customer support.

## 🎯 Requirements 

The system needs to:

1. Maintain data related to all airlines - `Airline` ✅
2. Allow customers to search for flights based on the desired date and the source/destination airport criteria - `Flight`, `FlightScheduleInstance` 🕵️‍♀️
3. Record customers’ personal information. Customers can reserve/cancel/view tickets for any scheduled flight or check the flight status - `Customer`, `Reservation`, `FlightScheduleInstance` 📝
4. Allow customers to create an itinerary consisting of multiple flights - `Itinerary`, `ItineraryFlight` 🌐
5. Enable customers to make a single reservation for multiple passengers under one itinerary - `Reservation`, `Passenger`, `ReservationPassenger` 🧑‍🤝‍🧑
6. Provide customers the option to cancel their itinerary and reservation - `Reservation`, `Itinerary` ❌
7. Assign crew members to flights - `CabinCrew`, `FlightScheduleInstance`, `Bridge` 👩‍✈️
8. Facilitate payment processing for reservations and send notifications to customers about their reservations and flight status updates - `Payment`, `Notification` 💲📣

## 🔗 Relations

(⚪ = 0 or more, 🔘 = 1 or more, 🔴 = exactly 1)

- 🔘 Airport can contain ⚪ flights, and each Flight must depart from and/or arrive at 🔘 airports.
- The airline operates 🔘 Aircraft and each Aircraft should belong to 🔴 airline.
- A customer has 🔴 account and the account belongs to 🔴 customer.
- Each Flight can have ⚪ Flight Instances scheduled but each flight instance should belong to 🔴 flight.
- Each Flight Instance can have 🔘 reservations made against it but each reservation should belong to 🔴 flight instance.
- Each customer can make ⚪ reservations, but each reservation can be made only by 🔴 customer.
- Each Reservation/Booking can trigger 🔘 notifications but each notification should belong to 🔴 reservation.
- Each reservation is associated with 🔴 payment and payment is associated with 🔴 reservation.
- Aircraft have 🔘 Flight Seats but each Flight Seat should belong to 🔴 Aircraft.
- Each reservation can contain 🔘 passengers, and a passenger can be part of ⚪ unique reservations.
- Each Reservation / Booking belongs to 🔴 Itinerary, A Reservation can be associated with 🔘 flights through a single Itinerary.
- Many to many relationship between `FlightScheduleInstance` and `Itinerary`.
- Many to many relationship between `FlightScheduleInstance` and `CabinCrew` table.

> A Reservation can be associated with multiple flights through a single Itinerary. 
> An Itinerary can be associated with multiple flights, but for one reservation

## 🔍 Use Cases

This database serves numerous use cases for an airline management system, including:

- Storing and maintaining data for all airlines, enabling easy access to airline information. 🏬
- Allowing customers to search for flights based on the desired date and source/destination airport criteria, ensuring a seamless booking experience. 🔎
- Recording customers' personal information, facilitating ticket reservations, cancellations, and flight status checks for any scheduled flight. 📚
- Enabling customers to create itineraries that consist of multiple flights, offering greater flexibility in travel planning. 🗓️
- Allowing customers to make single reservations for multiple passengers under one itinerary, streamlining the reservation process. 👨‍👩‍👧‍👦
- Providing customers with the option to cancel their itineraries and reservations, ensuring a hassle-free experience. ❌
- Assigning crew members to flights effectively, optimizing staff allocation for each flight instance. 👩‍✈️
- Facilitating payment processing for reservations and sending notifications to customers regarding their reservations and flight status updates, enhancing communication and transparency. 💰📢

## 🚀 Future Scope 

- Baggage Tracking 🛄
- Additional Services like in-flight meals 🥘
- Phone number format 📱
- Encryption of user passwords 🔒

## 👥 System Users 

- Customers 👥
- Passengers 🧑‍🤝‍🧑
- Airline Staff (Pilot, Attendant) 👩‍✈️
- System Admin 🛠️

## 📚 Stored Procedures

- **sp_search_flights**: Allows users to search for available flights based on departure date, departure airport code, and arrival airport code. It returns a list of active or scheduled flights that match the search criteria. 🔍
- **sp_get_customer_reservations**: Retrieves all reservations made by a particular customer along with the passengers associated with each reservation. 👥
- **sp_assign_crew_to_flight**: Checks if a crew member is available for a given flight instance before assigning them to the flight. If the crew member is not available, an error message is returned. 👩‍✈️
- **sp_cancel_reservation**: Cancels a reservation if it is not already canceled or checked-in. If the payment status is 'COMPLETED', it also updates the payment status to 'REFUNDED'. If the reservation is already canceled or checked-in, an error message is returned. ❌

## 🔫 Triggers

- **payment_completed_reservation_confirmed**: Executed after an update on the Payment table. If the updated payment status is 'COMPLETED', it checks if there's a reservation with the corresponding reservation_id and the status 'CONFIRMED'. If such a reservation exists, it inserts a new entry into the Notification table with the current date, the notification type 'email', the appropriate content, and the reservation_id. 💵📢

## 👁️ Views

- **FlightStatusView**: Retrieves the flight status information for all flight instances, along with the associated flight details. Users can query this view to get the flight status for a specific flight instance. 👁️
