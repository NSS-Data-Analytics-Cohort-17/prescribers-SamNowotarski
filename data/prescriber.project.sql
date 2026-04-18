----Prescribers Database
--q1a
SELECT prescriber.npi,
		SUM(prescription.total_claim_count) AS total_claims
		FROM prescriber
		INNER JOIN prescription ON prescription.npi = prescriber.npi
		GROUP BY prescriber.npi
		ORDER BY total_claims DESC;
--q1b
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description,
		SUM(prescription.total_claim_count) AS total_claims
		FROM prescriber
		INNER JOIN prescription ON prescription.npi = prescriber.npi
		GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
		ORDER BY total_claims DESC;
-------------------------------------------------


--q2a
SELECT  specialty_description,
		SUM(prescription.total_claim_count) AS total_claims
		FROM prescriber
		INNER JOIN prescription ON prescription.npi = prescriber.npi
		GROUP BY specialty_description
		ORDER BY total_claims DESC;


--q2b
SELECT  specialty_description,
		SUM(prescription.total_claim_count) AS total_claims
		FROM prescriber
		INNER JOIN prescription ON prescription.npi = prescriber.npi
		INNER JOIN drug ON drug.drug_name = prescription.drug_name
		WHERE opioid_drug_flag = 'Y'
		GROUP BY specialty_description
		ORDER BY total_claims DESC;


--q2c
SELECT DISTINCT specialty_description
FROM prescriber
LEFT JOIN prescription ON prescriber.npi = prescription.npi
WHERE prescription.npi IS NULL
ORDER BY specialty_description;
-----------------------


--q2d
SELECT  specialty_description,
		SUM(CASE WHEN opioid_drug_flag = 'Y' THEN prescription.total_claim_count ELSE 0 END) AS opioid_claims, 
		SUM(prescription.total_claim_count) AS total_claims,
        ROUND(100.0 * SUM(CASE WHEN opioid_drug_flag = 'Y' THEN prescription.total_claim_count ELSE 0 END) 
            / SUM(prescription.total_claim_count),2) AS opioid_percentage
FROM prescriber
INNER JOIN prescription ON prescription.npi = prescriber.npi
INNER JOIN drug ON drug.drug_name = prescription.drug_name
GROUP BY specialty_description
ORDER BY opioid_percentage DESC;


--q3a
SELECT generic_name, total_drug_cost
FROM drug INNER JOIN prescription ON drug.drug_name = prescription.drug_name
ORDER BY total_drug_cost DESC;
---PIRFENIDONE


--q3b
SELECT generic_name,
SUM(total_drug_cost) AS total_cost,
SUM(total_day_supply) AS total_days,
ROUND (SUM(total_drug_cost) / NULLIF(SUM(total_day_supply), 0)) AS cost_per_day
FROM drug
INNER JOIN prescription 
ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY cost_per_day DESC;
--C1 ESTERASE INHIBITOR
--q4a
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	 ELSE 'neither'
	 END AS drug_type
FROM drug
ORDER by drug_name DESC;
--q4b
SELECT 
CASE 
    WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
    END AS drug_type,
SUM(total_drug_cost)::money AS total_cost
FROM drug
INNER JOIN prescription ON prescription.drug_name = drug.drug_name
GROUP BY drug_type
ORDER BY total_cost DESC;
----
--q5a
SELECT COUNT(state)
FROM cbsa
INNER JOIN fips_county ON fips_county.fipscounty = cbsa.fipscounty
WHERE state = 'TN';
---42
--q5b
SELECT SUM(population) AS total_population,  cbsaname
FROM cbsa
INNER JOIN fips_county ON fips_county.fipscounty = cbsa.fipscounty
INNER JOIN population ON fips_county.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY total_population DESC;
---q5c
SELECT 
    county,
    population
FROM fips_county
INNER JOIN population 
    ON population.fipscounty = fips_county.fipscounty
LEFT JOIN cbsa 
    ON cbsa.fipscounty = fips_county.fipscounty
WHERE cbsa.fipscounty IS NULL
ORDER BY population.population DESC;
------
--q6a
SELECT drug.drug_name, total_claim_count
FROM prescription
INNER JOIN drug ON drug.drug_name = prescription.drug_name
WHERE total_claim_count >= 3000;
-----------------
--q6b
SELECT drug.drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug ON drug.drug_name = prescription.drug_name
WHERE total_claim_count >= 3000;
-------
--q6c
SELECT drug.drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
INNER JOIN drug ON drug.drug_name = prescription.drug_name
INNER JOIN prescriber ON prescription.npi = prescriber.npi
WHERE total_claim_count >= 3000;

--q7a
SELECT prescriber.npi, drug.drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' 
AND opioid_drug_flag = 'Y' 
AND nppes_provider_city = 'NASHVILLE';
---
--q7b
SELECT 
    prescriber.npi, 
    drug.drug_name, 
    COALESCE(SUM(prescription.total_claim_count), 0) AS total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription 
    ON prescriber.npi = prescription.npi 
   AND drug.drug_name = prescription.drug_name
WHERE prescriber.specialty_description = 'Pain Management' 
  AND prescriber.nppes_provider_city = 'NASHVILLE'
  AND drug.opioid_drug_flag = 'Y'
GROUP BY 
    prescriber.npi, 
    drug.drug_name;








	