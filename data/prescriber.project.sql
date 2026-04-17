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
WHERE prescription.npi IS NULL;
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
SUM(total_drug_cost) / NULLIF(SUM(total_day_supply), 0) AS cost_per_day
FROM drug
INNER JOIN prescription 
ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY cost_per_day DESC


	