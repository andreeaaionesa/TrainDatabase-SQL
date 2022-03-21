CREATE OR ALTER PROC uspUpdateRoute (@RName VARCHAR(50), @SName VARCHAR(50), @Arrival TIME, @Departure TIME)
AS
  DECLARE @SID INT, @RID INT

  IF NOT EXISTS(SELECT * FROM Station WHERE SName = @SName)
  BEGIN
     RAISERROR('Invalid station name. ', 16, 1)
	 RETURN
  END

  IF NOT EXISTS(SELECT * FROM Routes WHERE RName = @RName)
  BEGIN
     RAISERROR('Invalid route name. ', 16, 1)
	 RETURN
  END

  SELECT @SID = (SELECT SID FROM Station WHERE Sname = @SName),
      @RID = (SELECT RID FROM Routes WHERE RName = @RName)

  IF EXISTS (SELECT *
            FROM StationRoutes
			WHERE SID = @SID AND RID = @RID)
		UPDATE StationRoutes
		SET Arrival = @Arrival, Departure = @Departure
		WHERE SID = @SID AND RID = @RID
	 ELSE
	     INSERT StationRoutes(SID,RID,Arrival,Departure)
		 VALUES (@SID, @RID, @Arrival, @Departure)
GO

SELECT * FROM TrainTypes
SELECT * FROM Trains 
SELECT * FROM Routes 
SELECT * FROM Station
SELECT * FROM StationRoutes 
ORDER BY RID

INSERT TrainTypes VALUES (1, 'typel', 'descr'), (2, 'type2', 'descr')
INSERT Trains VALUES(1, 't1', 1) (2, 't2', 1), (3, 't3', 1)
INSERT Routes VALUES (1, 'rl', 1), (2, 'r2', 2), (3, 'r3', 3)
INSERT Station VALUES (1, 's1'), (2, 's2'), (3, 's3')

EXEC uspUpdateRoute @RName = 'r1', @SName = 's7', @Arrival = '6:10', @Departure = '6:20'

EXEC uspUpdateRoute @RName = 'r1', @SName = 's1', @Arrival = '8:00', @Departure = '9:50'
EXEC uspUpdateRoute @RName = 'r1', @SName = 's2', @Arrival = '7:10', @Departure = '10:20'
EXEC uspUpdateRoute @RName = 'r1', @SName = 's3', @Arrival = '5:10', @Departure = '5:30'

EXEC uspUpdateRoute @RName = 'r2', @SName = 's1', @Arrival = '8:10', @Departure = '9:20'
EXEC uspUpdateRoute @RName = 'r2', @SName = 's2', @Arrival = '7:10', @Departure = '7:20'
EXEC uspUpdateRoute @RName = 'r2', @SName = 's3', @Arrival = '11:10', @Departure = '12:20'

EXEC uspUpdateRoute @RName = 'r3', @SName = 's1', @Arrival = '7:30', @Departure = '7:40'

--C
CREATE OR ALTER VIEW vRoutesWithAllStations
AS
  SELECT r.RName
  FROM Routes r
  WHERE NOT EXISTS
    (SELECT SID
	FROM Station 
	EXCEPT
	SELECT SID
	FROM StationRoutes
	WHERE RID = r.RID)
GO

SELECT *
FROM vRoutesWithAllStations
GO

--D

SELECT*
FROM StationRoutes
GO

CREATE OR ALTER FUNCTION ufFilterStationsByNumOfRoutes(@R INT)
RETURNS TABLE
RETURN SELECT S.SName
  FROM Station S
  WHERE S.SID IN
    (SELECT SR.SID
	FROM StationRoutes SR
	GROUP BY SR.SID
	HAVING COUNT(*) >@R)
GO

SELECT*
FROM ufFilterStationsByNumOfRoutes (3)
