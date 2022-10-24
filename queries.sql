/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';
SELECT * FROM animals WHERE extract(YEAR FROM date_of_birth) BETWEEN '2016' AND '2019';
SELECT * FROM animals WHERE neutered = true AND escape_attempts < 3;
SELECT date_of_birth FROM animals WHERE name = 'Angemon' OR name = 'Pikachu';
SELECT name,escape_attempts  FROM animals WHERE weight_kg > 10.5;
SELECT * FROM animals WHERE neutered = true;
SELECT * FROM animals WHERE name != 'Squirtle';
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

-- TRANSACTION
BEGIN;

UPDATE animals SET species = 'unspecified';

ROLLBACK;

BEGIN;

UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE name NOT LIKE '%mon';

COMMIT;

BEGIN;

DELETE FROM animals;

ROLLBACK;

BEGIN;

SAVEPOINT SP1;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';

ROLLBACK TO SP1;

SAVEPOINT SP2;
UPDATE animals SET weight_kg=weight_kg * -1;

ROLLBACK TO SP2;

UPDATE animals SET weight_kg=weight_kg * -1;

COMMIT;

-- SOME OTHER QUERIES
-- How many animals are there?
SELECT count(*) AS total_animals FROM animals;

-- How many animals have never tried to escape?
SELECT count(*) AS never_tried_to_escape FROM animals WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT CAST(AVG(weight_kg) AS DECIMAL(5,2)) AS average_weight FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT name, MAX(escape_attempts) AS most_escape FROM animals WHERE neutered = true OR neutered = false GROUP BY name ORDER BY MAX(escape_attempts) DESC;

-- What is the minimum and maximum weight of each type of animal?
SELECT MIN(weight_kg) AS min_weight, MAX(weight_kg) AS max_weight FROM animals;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT CAST(AVG(escape_attempts) AS DECIMAL(5,2)) AS average_escape_attempts FROM animals WHERE extract(YEAR FROM date_of_birth) BETWEEN '1990' AND '2000';


-- JOIN QUERIES
-- What animals belong to Melody Pond?
SELECT 
an.name AS animal_name,
ow.full_name AS owner_name 
FROM animals an 
INNER JOIN owners ow
ON ow.id = an.owners_id 
WHERE ow.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT 
an.name AS animal_name, 
sp.name AS species 
FROM animals an 
INNER JOIN species sp
ON sp.id = an.species_id
WHERE sp.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT
ow.full_name as owner_name,
an.name as animal_name
FROM owners ow
LEFT JOIN animals an
ON ow.id = an.owners_id;

-- How many animals are there per species?
SELECT 
sp.name AS species_name,
COUNT(an.name) AS animal_count
FROM animals an 
INNER JOIN species sp
ON sp.id = an.species_id
GROUP BY sp.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT 
ow.full_name as owner_name,
sp.name as species_name,
an.name as animal_name
FROM animals an 
INNER JOIN owners ow
ON ow.id = an.owners_id
INNER JOIN species sp
ON sp.id = an.owners_id
WHERE ow.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT 
ow.full_name as owner_name,
an.name as animal_name,
an.escape_attempts as check_attempts
FROM animals an 
INNER JOIN owners ow
ON ow.id = an.owners_id
WHERE an.escape_attempts = 0 
AND ow.full_name = 'Dean Winchester';

-- Who owns the most animals?
SELECT 
COUNT(an.name) AS animal_count,
ow.full_name AS owner_name 
FROM animals an 
INNER JOIN owners ow
ON ow.id = an.owners_id 
GROUP BY ow.full_name 
ORDER BY MAX(an.name) DESC;

-- Who was the last animal seen by William Tatcher? 
SELECT 
an.name as animal_name,
ve.name as vet_name,
vi.visit_date
FROM animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'William Tatcher' 
ORDER BY vi.visit_date DESC LIMIT 1; 

-- How many different animals did Stephanie Mendez see?
SELECT 
ve.name AS vet_name,
COUNT(an.name) AS animal_count
FROM
animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'Stephanie Mendez'
GROUP BY ve.name;

-- List all vets and their specialties, including vets with no specialties.
SELECT 
ve.name AS vet_name,
sp.name AS animal_type 
FROM
vets ve
LEFT JOIN specializations spe 
ON ve.id = spe.vet_id
LEFT JOIN species sp 
ON spe.species_id = sp.id 
ORDER BY ve.name;


-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT
ve.name AS vet_name,
an.name AS animal_name,
vi.visit_date AS visit_date
FROM
animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'Stephanie Mendez' 
AND 
vi.visit_date BETWEEN '2020-04-01' AND '2020-08-30';

-- What animal has the most visits to vets?
SELECT
an.name AS animal_name,
COUNT(vi.animal_id) AS most_visits
FROM
animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
GROUP BY an.name
ORDER BY COUNT(vi.animal_id) DESC LIMIT 1;


-- Who was Maisy Smith's first visit?
SELECT 
an.name as animal_name,
ve.name as vet_name,
vi.visit_date
FROM animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'Maisy Smith'
ORDER BY visit_date ASC LIMIT 1;

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT
an.name AS animal_name,
an.date_of_birth,
an.escape_attempts,
an.neutered,
an.weight_kg,
ve.name AS vet_name,
ve.age,
ve.date_of_graduation,
vi.visit_date
FROM
animals an
INNER JOIN visits vi
ON an.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
ORDER BY vi.visit_date DESC LIMIT 1;

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT
ve.name AS vet_name,
COUNT(vi.vet_id) AS visit_count
FROM
species sp
RIGHT JOIN specializations spe
ON sp.id = spe.species_id
RIGHT JOIN vets ve
ON ve.id = spe.vet_id
RIGHT JOIN visits vi
ON ve.id = vi.vet_id
WHERE ve.name = 'Maisy Smith'
GROUP BY ve.name;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT
DISTINCT
ve.name AS vet_name,
an.name AS animal_name,
MAX(sp.name) AS animal_type
FROM
animals an
RIGHT JOIN visits vi
ON an.id = vi.animal_id
RIGHT JOIN species sp
ON sp.id = an.species_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'Maisy Smith' 
GROUP BY ve.name, an.name
ORDER BY an.name ASC LIMIT 1;


-- Check data performance
explain analyze SELECT COUNT(animal_id) FROM visits where animal_id = 4;

explain analyze SELECT animal_id, vet_id, visit_date FROM visits where vet_id = 2;

explain analyze SELECT full_name, age, email FROM owners where email = 'owner_18327@mail.com';

