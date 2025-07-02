<?php
declare(strict_types=1);

class PrefixGenerator
{
    private string $csvFile = 'MAJNUM.csv';
    private string $csvUrl = 'https://extranet.arcep.fr/uploads/MAJNUM.csv';
    private string $jsonFile = 'saracroche/prefixes.json';
    private array $blockedOperators = [
        'DVSC', 'LGC', 'ZETE', 'OXIL', 'BJTP', 'UBIC', 'OPEN', 'KAVE', 'SPAR',
    ];
    private array $arcepPrefixes = [
        '33162', '33163', '33270', '33271', '33377', '33378',
        '33424', '33425', '33568', '33569', '33948', '33949',
        '339475', '339476', '339477', '339478', '339479',
    ];
    private array $output = [];

    public function __construct()
    {
        $this->downloadCsv();
        $this->addArcepPrefixes();
        $this->processCsv();
        $this->writeJson();
        $this->countTotalNumbers();
    }

    public function downloadCsv(): void
    {
        echo "⬇️ Téléchargement du fichier CSV depuis {$this->csvUrl}...\n";
        $csvData = file_get_contents($this->csvUrl);
        if ($csvData === false) {
            die("❌ Erreur lors du téléchargement du fichier CSV.\n");
        }
        file_put_contents($this->csvFile, $csvData);
        echo "✅ Fichier CSV téléchargé avec succès.\n";
    }

    public function addArcepPrefixes(): void
    {
        foreach ($this->arcepPrefixes as $prefix) {
            $nbDigitsToFill = 11 - strlen($prefix);
            $pattern = $prefix . str_repeat('#', $nbDigitsToFill);
            $this->output[] = [
                'operator' => 'ARCEP',
                'prefix' => $pattern
            ];
        }
    }

    public function processCsv(): void
    {
        $handle = fopen($this->csvFile, 'r');
        if ($handle === false) return;
        $headers = fgetcsv($handle, 1000, ';', '"', "\n");
        $headers = array_map(function ($h) {
            return mb_convert_encoding($h, 'UTF-8', 'ISO-8859-1');
        }, $headers);
        while (($data = fgetcsv($handle, 1000, ';', '"', "\n")) !== false) {
            $data = array_map(function ($d) {
                return mb_convert_encoding($d, 'UTF-8', 'ISO-8859-1');
            }, $data);
            $row = array_combine($headers, $data);
            $ezabpqm = $row['EZABPQM'];
            $operator = $row['Mnémo'];
            if (in_array($operator, $this->blockedOperators) && preg_match('/^\d+$/', $ezabpqm)) {
                $ezabpqm = ltrim($ezabpqm, '0');
                $numericPrefix = '33' . $ezabpqm;
                echo "🔍 Préfixe trouvé : $numericPrefix pour l'opérateur $operator\n";
                $isPrefixBlocked = false;
                foreach ($this->arcepPrefixes as $arcepPrefix) {
                    if (strpos($numericPrefix, $arcepPrefix) === 0) {
                        echo "❌ Préfixe $numericPrefix est déjà bloqué par le préfixe ARCEP : $arcepPrefix\n";
                        $isPrefixBlocked = true;
                        break;
                    }
                }
                if ($isPrefixBlocked) continue;
                $nbDigitsToFill = 11 - strlen($numericPrefix);
                $pattern = $numericPrefix . str_repeat('#', $nbDigitsToFill);
                $this->output[] = [
                    'operator' => $operator,
                    'prefix' => $pattern
                ];
            }
        }
        fclose($handle);
    }

    public function writeJson(): void
    {
        file_put_contents($this->jsonFile, json_encode($this->output, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        echo "✅ Fichier JSON généré avec succès !\n";
    }

    public function countTotalNumbers(): int
    {
        $totalNumbers = 0;
        foreach ($this->output as $entry) {
            $prefix = $entry['prefix'];
            $numHashes = substr_count($prefix, '#');
            $possibleNumbers = pow(10, $numHashes);
            $totalNumbers += $possibleNumbers;
        }
        echo "🟰 Nombre total de numéros possibles pour tous les préfixes : {$totalNumbers}\n";
        return $totalNumbers;
    }
}

new PrefixGenerator();
