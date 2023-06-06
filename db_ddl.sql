DROP DATABASE IF EXISTS airline_reservation_system;

CREATE DATABASE airline_reservation_system;

USE airline_reservation_system;

CREATE TABLE Address(
   address_id INT AUTO_INCREMENT PRIMARY KEY,
   zip_code VARCHAR(12) NOT NULL,
   street VARCHAR(30),
   city VARCHAR(20) NOT NULL,
   state VARCHAR(20) NOT NULL,
   country VARCHAR(20) NOT NULL
);

CREATE TABLE Airport (
    airport_code CHAR(3) PRIMARY KEY,
    airport_name VARCHAR(40) NOT NULL,
    airport_address_id INT UNIQUE NOT NULL, 
    FOREIGN KEY (airport_address_id) REFERENCES Address(address_id)
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(40) NOT NULL,
    address_id INT UNIQUE NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    DOB DATE NOT NULL, 
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

CREATE TABLE Account (
    account_id INT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    account_status VARCHAR(20) NOT NULL CHECK (account_status IN ('ACTIVE', 'CLOSED', 'BLOCKED')),
    customer_id INT UNIQUE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id)
);

CREATE TABLE CabinCrew (
    crew_member_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    hire_date DATE NOT NULL,
    job_title ENUM('ATTENDANT', 'PILOT') NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(40) NOT NULL,
    address_id INT UNIQUE NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    dob DATE NOT NULL,
    base_location VARCHAR(30) NOT NULL,
    FOREIGN KEY (address_id) REFERENCES Address (address_id)
);

CREATE TABLE Airline (
    airline_code CHAR(2) PRIMARY KEY,
    airline_name VARCHAR(40) NOT NULL
);

CREATE TABLE Aircraft (
    aircraft_code CHAR(5) PRIMARY KEY,
    aircraft_name VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    no_of_seats INT NOT NULL,
    airline_code CHAR(2) NOT NULL,
    FOREIGN KEY (airline_code) REFERENCES Airline (airline_code)
);

CREATE TABLE FlightSeat (
    seat_number VARCHAR(10) PRIMARY KEY,
    fare DECIMAL(10, 2) NOT NULL,
    seat_type ENUM('REGULAR', 'EXTRA_LEG_ROOM') NOT NULL,
    seat_class VARCHAR(20) NOT NULL CHECK (seat_class IN ('ECONOMY', 'BUSINESS', 'FIRST_CLASS')),
    aircraft_code CHAR(5) NOT NULL,
    FOREIGN KEY (aircraft_code) REFERENCES Aircraft(aircraft_code)
);

CREATE TABLE Flight (
    flight_number CHAR(10) PRIMARY KEY,
    departure_airport_code CHAR(3) NOT NULL,
    arrival_airport_code CHAR(3) NOT NULL,
    distance INT NOT NULL,
    duration_hours DECIMAL(4,2) NOT NULL,
    FOREIGN KEY (departure_airport_code) REFERENCES Airport (airport_code),
    FOREIGN KEY (arrival_airport_code) REFERENCES Airport (airport_code)
);

CREATE TABLE FlightScheduleInstance (
    flight_instance_id INT PRIMARY KEY,
    flight_number CHAR(10) NOT NULL,
    departure_date_time DATETIME NOT NULL,
    arrival_date_time DATETIME NOT NULL,
	actual_departure_date_time DATETIME,
    actual_arrival_date_time DATETIME,
    gate VARCHAR(20) NOT NULL,
    aircraft_code CHAR(5) UNIQUE NOT NULL,
    flight_status VARCHAR(20) CHECK (flight_status IN ('ACTIVE', 'SCHEDULED', 'DELAYED', 'DEPARTED', 'LANDED', 'IN_AIR', 'ARRIVED', 'CANCELLED')) NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (flight_number) REFERENCES Flight (flight_number),
    FOREIGN KEY (aircraft_code) REFERENCES Aircraft(aircraft_code)
);

CREATE TABLE Passenger (
    passenger_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    dob DATE NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(40) NOT NULL UNIQUE,
    passport_number VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Itinerary (
    itinerary_id INT PRIMARY KEY,
    passenger_id INT NOT NULL,
    source_airport_code CHAR(3) NOT NULL,
    destination_airport_code CHAR(3) NOT NULL,
    creation_date DATETIME NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES Passenger (passenger_id),
    FOREIGN KEY (source_airport_code) REFERENCES Airport (airport_code),
    FOREIGN KEY (destination_airport_code) REFERENCES Airport (airport_code)
);

CREATE TABLE Reservation (
    reservation_id INT PRIMARY KEY,
    flight_instance_id INT NOT NULL,
    reservation_status VARCHAR(20) NOT NULL,
    reservation_date DATETIME NOT NULL,
    customer_id INT NOT NULL,
    itinerary_id INT UNIQUE,
    FOREIGN KEY (flight_instance_id) REFERENCES FlightScheduleInstance (flight_instance_id),
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id),
    FOREIGN KEY (itinerary_id) REFERENCES Itinerary (itinerary_id) ON DELETE SET NULL
);


ALTER TABLE Reservation
ADD CONSTRAINT chk_reservation_status CHECK (reservation_status IN ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CANCELLED'));

CREATE INDEX idx_reservation_customer_id ON Reservation (customer_id);
CREATE INDEX idx_reservation_flight_instance_id ON Reservation (flight_instance_id);

CREATE TABLE Payment (
	payment_id INT PRIMARY KEY,
	fare DECIMAL(10,2) NOT NULL,
	tax DECIMAL(10,2) NOT NULL,
	payment_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
	reservation_id INT UNIQUE NOT NULL,
	FOREIGN KEY (reservation_id) REFERENCES Reservation (reservation_id) ON DELETE CASCADE
);

ALTER TABLE Payment
ADD CONSTRAINT chk_payment_status CHECK (payment_status IN ('UNPAID', 'PENDING', 'COMPLETED', 'DECLINED', 'CANCELLED', 'REFUNDED'));

CREATE TABLE Notification (
	notification_id INT PRIMARY KEY,
	notification_date DATETIME NOT NULL,
	notification_type VARCHAR(255) NOT NULL,
	notification_content TEXT NOT NULL,
	reservation_id INT NOT NULL,
	FOREIGN KEY (reservation_id) REFERENCES Reservation (reservation_id) ON DELETE CASCADE,
	CHECK (notification_type IN ('SMS', 'EMAIL'))
);

ALTER TABLE Notification MODIFY COLUMN notification_id INT AUTO_INCREMENT;

CREATE TABLE ReservationPassenger (
    reservation_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(10) UNIQUE NOT NULL,
    PRIMARY KEY (reservation_id, passenger_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation (reservation_id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES Passenger (passenger_id),
    FOREIGN KEY (seat_number) REFERENCES FlightSeat (seat_number)
);

CREATE TABLE ItineraryFlight (
    itinerary_id INT NOT NULL,
    flight_instance_id INT NOT NULL,
    PRIMARY KEY (itinerary_id, flight_instance_id),
    FOREIGN KEY (itinerary_id) REFERENCES Itinerary (itinerary_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_instance_id) REFERENCES FlightScheduleInstance (flight_instance_id)
);

CREATE TABLE CrewAvailability (
    crew_member_id INT,
    start_date_time DATETIME NOT NULL,
    end_date_time DATETIME NOT NULL,
    PRIMARY KEY (crew_member_id, start_date_time, end_date_time),
    FOREIGN KEY (crew_member_id) REFERENCES CabinCrew (crew_member_id) ON DELETE CASCADE
);

CREATE TABLE Bridge (
    crew_member_id INT not null,
    flight_instance_id INT not null,
    PRIMARY KEY (crew_member_id, flight_instance_id),
    FOREIGN KEY (crew_member_id) REFERENCES CabinCrew (crew_member_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_instance_id) REFERENCES FlightScheduleInstance (flight_instance_id) ON DELETE CASCADE
);


-- stored procedure sp_search_flights returns a list of available flights based on the search criteria and 
-- flight status should be in 'ACTIVE', 'SCHEDULED'

DELIMITER //

CREATE PROCEDURE sp_search_flights (
    IN p_departure_date DATE,
    IN p_departure_airport_code CHAR(3),
    IN p_arrival_airport_code CHAR(3)
)
BEGIN
    SELECT
        f.flight_number,
        f.departure_airport_code,
        f.arrival_airport_code,
        f.distance,
        f.duration_hours,
        a.airline_name,
        ac.aircraft_name,
        ac.model,
        ac.no_of_seats,
        fsi.departure_date_time,
        fsi.arrival_date_time,
        fsi.flight_status
    FROM
        Flight AS f
        INNER JOIN FlightScheduleInstance AS fsi ON f.flight_number = fsi.flight_number
        INNER JOIN Aircraft AS ac ON fsi.aircraft_code = ac.aircraft_code
        INNER JOIN Airline AS a ON ac.airline_code = a.airline_code
    WHERE
        DATE(fsi.departure_date_time) = p_departure_date
        AND f.departure_airport_code = p_departure_airport_code
        AND f.arrival_airport_code = p_arrival_airport_code
        AND fsi.flight_status IN ('ACTIVE', 'SCHEDULED');
END //

DELIMITER ;


-- CALL sp_search_flights('2023-05-01', 'DCA', 'LAX');



-- stored procedure sp_get_customer_reservations to get all reservations made by a particular customer 
-- along with the passengers for each reservation

DELIMITER //

CREATE PROCEDURE sp_get_customer_reservations (
    IN p_customer_id INT
)
BEGIN
    SELECT
        r.reservation_id,
        r.flight_instance_id,
        r.reservation_status,
        r.reservation_date,
        p.passenger_id,
        p.first_name AS passenger_first_name,
        p.last_name AS passenger_last_name,
        p.gender AS passenger_gender,
        p.dob AS passenger_dob,
        p.phone_number AS passenger_phone_number,
        p.email AS passenger_email,
        p.passport_number AS passenger_passport_number,
        rp.seat_number
    FROM
        Reservation AS r
        INNER JOIN ReservationPassenger AS rp ON r.reservation_id = rp.reservation_id
        INNER JOIN Passenger AS p ON rp.passenger_id = p.passenger_id
    WHERE
        r.customer_id = p_customer_id;
END //

DELIMITER ;

-- CALL sp_get_customer_reservations(1);
-- select * from Reservation limit 10;



-- retrieve the flight status information for all flight instances, along with the associated flight details

CREATE VIEW FlightStatusView AS
SELECT
    fsi.flight_instance_id,
    f.flight_number,
    f.departure_airport_code,
    f.arrival_airport_code,
    fsi.departure_date_time,
    fsi.arrival_date_time,
    fsi.actual_departure_date_time,
    fsi.actual_arrival_date_time,
    fsi.flight_status
FROM
    FlightScheduleInstance fsi
JOIN
    Flight f ON fsi.flight_number = f.flight_number;

SELECT * FROM FlightStatusView;


-- stored procedure checks if the crew member is available for the given flight instance before assigning them to the flight. 
-- If the crew member is not available, an error message will be returned.

DELIMITER //

CREATE PROCEDURE sp_assign_crew_to_flight (
    IN p_crew_member_id INT,
    IN p_flight_instance_id INT
)
BEGIN
    DECLARE v_crew_availability INT DEFAULT 0;

    -- Check if the crew member is available for the given flight instance
    SELECT
        COUNT(*)
    INTO
        v_crew_availability
    FROM
        CrewAvailability ca
        JOIN FlightScheduleInstance fsi ON p_flight_instance_id = fsi.flight_instance_id
    WHERE
        ca.crew_member_id = p_crew_member_id
        AND ca.start_date_time <= fsi.departure_date_time
        AND ca.end_date_time >= fsi.arrival_date_time;

    IF v_crew_availability > 0 THEN
        -- Assign the crew member to the flight
        INSERT INTO Bridge (crew_member_id, flight_instance_id)
        VALUES (p_crew_member_id, p_flight_instance_id);
    ELSE
        SELECT 'Crew member is not available for the given flight instance' AS ErrorMessage;
    END IF;
END //

DELIMITER ;

-- Test Data:
-- INSERT INTO Address (zip_code, street, city, state, country) VALUES
-- ('98101', '1234 Pine St', 'Seattle', 'Washington', 'USA');
-- select * from Address;

-- INSERT INTO CabinCrew (crew_member_id, first_name, last_name, hire_date, job_title, status, phone_number, email, address_id, gender, dob, base_location) VALUES
-- (5, 'Sophia', 'Martinez', '2019-06-01', 'ATTENDANT', 'ACTIVE', '+18234567890', 'sophia.martinez@example.com', 5, 'FEMALE', '1994-08-20', 'SEA');

-- INSERT INTO CrewAvailability (crew_member_id, start_date_time, end_date_time) VALUES
-- (5, '2023-05-01 09:45:00', '2023-05-01 19:00:00');

-- CALL sp_assign_crew_to_flight(5, 1); -- Crew member is not available for the given flight instance
-- CALL sp_assign_crew_to_flight(5, 2);
-- select * from Bridge;


-- stored procedure: 
-- If the reservation is not already canceled or checked-in, it will update the reservation_status to 'CANCELLED'. 
-- If the payment_status is 'COMPLETED', it will also update the payment_status to 'REFUNDED'. 
-- If the reservation is already canceled or checked in, it will return an error message.

DELIMITER //

CREATE PROCEDURE sp_cancel_reservation (
    IN p_reservation_id INT
)
BEGIN
    DECLARE v_payment_status VARCHAR(20);
    DECLARE v_reservation_status VARCHAR(20);

    -- Check the current reservation_status and payment_status
    SELECT reservation_status, payment_status
    INTO v_reservation_status, v_payment_status
    FROM Reservation
    JOIN Payment ON Reservation.reservation_id = Payment.reservation_id
    WHERE Reservation.reservation_id = p_reservation_id;

    IF v_reservation_status NOT IN ('CANCELLED', 'CHECKED_IN') THEN
        -- Update reservation_status to 'CANCELLED'
        UPDATE Reservation
        SET reservation_status = 'CANCELLED'
        WHERE reservation_id = p_reservation_id;

        -- Update payment_status to 'REFUNDED' if payment was 'COMPLETED'
        IF v_payment_status = 'COMPLETED' THEN
            UPDATE Payment
            SET payment_status = 'REFUNDED'
            WHERE reservation_id = p_reservation_id;
        END IF;
    ELSE
        SELECT 'Cannot cancel the reservation as it is already canceled or checked-in' AS ErrorMessage;
    END IF;
END //

DELIMITER ;


-- Test Data
-- INSERT INTO Customer (customer_id, first_name, last_name, phone_number, email, address_id, gender, DOB) VALUES (5, 'Olivia', 'Lee', '+15234567890', 'olivia.lee@example.com', 5, 'FEMALE', '1992-10-25');

-- INSERT INTO Reservation (reservation_id, flight_instance_id, reservation_status, reservation_date, customer_id, itinerary_id) VALUES (5, 1, 'CONFIRMED', '2023-04-24 12:00:00', 5, NULL);

-- INSERT INTO Account (account_id, password, account_status, customer_id) VALUES (5, 'hashed_password_5', 'ACTIVE', 5);

-- INSERT INTO Payment (payment_id, fare, tax, payment_status, reservation_id) VALUES (5, 250.00, 25.00, 'COMPLETED', 5);

-- INSERT INTO Passenger (passenger_id, first_name, last_name, gender, dob, phone_number, email, passport_number) VALUES (5, 'Liam', 'Harris', 'MALE', '1998-09-05', '+21234567890', 'liam.harris@example.com', 'P567890123');

-- use existing seat 11B
-- INSERT INTO ReservationPassenger (reservation_id, passenger_id, seat_number) VALUES (5, 5, '11B');

-- CALL sp_cancel_reservation(5);

-- SET @x := NULL;
-- SELECT @x := reservation_id, payment_status FROM Payment WHERE payment_id = 5;
-- SELECT reservation_status FROM Reservation WHERE reservation_id = @x;
-- CALL sp_cancel_reservation(3); -- Cannot cancel the reservation as it is already canceled or checked-in
-- select * from address;
-- select * from Reservation;


-- To create a trigger that inserts a notification entry when a payment is completed and a reservation is confirmed 

-- This trigger will be executed after an update on the Payment table. If the updated payment status is 'COMPLETED', 
-- it will check if there's a reservation with the corresponding reservation_id and the status 'CONFIRMED'. 
-- If such a reservation exists, it will insert a new entry into the Notification table with the current date, 
-- the notification type 'email', the appropriate content, and the reservation_id. 

DELIMITER //
CREATE TRIGGER payment_completed_reservation_confirmed
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'COMPLETED' THEN
        SET @reservation_status := (SELECT reservation_status FROM Reservation WHERE reservation_id = NEW.reservation_id);
        
        IF @reservation_status = 'CONFIRMED' THEN
            INSERT INTO Notification (notification_date, notification_type, notification_content, reservation_id)
            VALUES (NOW(), 'email', CONCAT('Dear customer, your payment for reservation ID ', NEW.reservation_id, ' has been completed and your reservation is now confirmed. Please check your itinerary for details.'), NEW.reservation_id);
        END IF;
    END IF;
END //
DELIMITER ;


-- select * from Reservation;
-- select * from Payment;

-- The trigger now selects the reservation_status of the corresponding reservation_id and checks if it's 'CONFIRMED' before inserting the notification.
-- Testing the trigger

-- Initial Payment Status Pending
-- UPDATE Reservation SET reservation_status = 'CONFIRMED' where reservation_id = 2;
-- UPDATE Payment SET payment_status = 'COMPLETED' WHERE reservation_id = 2;
-- SELECT * FROM Notification;

