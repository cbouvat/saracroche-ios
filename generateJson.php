<?php

$csvFile = 'MAJNUM.csv';
$jsonFile = 'saracroche/prefixes.json';

// Définir ici les opérateurs à inclure. Laisser vide pour tout inclure.
$blockedOperators = [
  'DVSC',
  'LGC',
  'ZETE',
  'OXIL',
  'BJTP',
  'UBIC',
  'OPEN',
  'KAVE',
  'SPAR',
];

$handle = fopen($csvFile, 'r');
$output = [];

// Ajouter les préfixes Arcep
$arcepPrefixes = [
  '33162',
  '33163',
  '33270',
  '33271',
  '33377',
  '33378',
  '33424',
  '33425',
  '33568',
  '33569',
  '33948',
  '33949',
  '339475',
  '339476',
  '339477',
  '339478',
  '339479',
];

foreach ($arcepPrefixes as $prefix) {
  $nbDigitsToFill = 11 - strlen($prefix);
  $pattern = $prefix . str_repeat('#', $nbDigitsToFill);
  $output[] = [
    'operator' => 'ARCEP',
    'prefix' => $pattern
  ];
}

if ($handle !== false) {
  $headers = fgetcsv($handle, 1000, ';', '"', "\n"); // Lire l'en-tête
  $headers = array_map(function ($h) {
    return mb_convert_encoding($h, 'UTF-8', 'ISO-8859-1');
  }, $headers);

  while (($data = fgetcsv($handle, 1000, ';', '"', "\n")) !== false) {
    // Convertir chaque champ en UTF-8
    $data = array_map(function ($d) {
      return mb_convert_encoding($d, 'UTF-8', 'ISO-8859-1');
    }, $data);
    $row = array_combine($headers, $data);

    $ezabpqm = $row['EZABPQM'];
    $operator = $row['Mnémo'];

    if (in_array($operator, $blockedOperators) && preg_match('/^\d+$/', $ezabpqm)) {
      // Retirer le premier 0 si présent
      $ezabpqm = ltrim($ezabpqm, '0');

      // Créer le préfixe E.164 : +33 + EZABPQM
      $numericPrefix = '33' . $ezabpqm;

      echo "🔍 Préfixe trouvé : $numericPrefix pour l'opérateur $operator\n";

      // Vérifier qu'un préfixe ne commence par un préfixe déjà existant dans la liste $arcepPrefixes
      $isPrefixBlocked = false;
      foreach ($arcepPrefixes as $arcepPrefix) {
        if (strpos($numericPrefix, $arcepPrefix) === 0) {
          echo "❌ Préfixe $numericPrefix est déjà bloqué par le préfixe ARCEP : $arcepPrefix\n";
          $isPrefixBlocked = true;
          break;
        }
      }

      if ($isPrefixBlocked) {
        continue; // Passer à l'itération suivante si le préfixe est bloqué
      }

      $nbDigitsToFill = 11 - strlen($numericPrefix); // max E.164: 11 digits
      $pattern = $numericPrefix . str_repeat('#', $nbDigitsToFill);

      $output[] = [
        'operator' => $operator,
        'prefix' => $pattern
      ];
    }
  }

  fclose($handle);
}

// Écriture JSON
file_put_contents($jsonFile, json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

// Calculer le nombre total de numéros possibles pour chaque préfixe dans $output
$totalNumbers = 0;

foreach ($output as $entry) {
  $prefix = $entry['prefix'];
  $numHashes = substr_count($prefix, '#');
  $possibleNumbers = pow(10, $numHashes);
  $totalNumbers += $possibleNumbers;
}

echo "✅ Fichier JSON généré avec succès !\n";
echo "🟰 Nombre total de numéros possibles pour tous les préfixes : {$totalNumbers}\n";
echo "🗂️ Fichier JSON généré : $jsonFile\n";
