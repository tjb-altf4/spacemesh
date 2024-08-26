#!/bin/bash
# spacemesh reward exporter

# coinbase is provided in bech32 format (sm1qqqqq)), this must be converted to hex for this script
# decode bech32 to hex using https://slowli.github.io/bech32-buffer/

COINBASE_HEX=00000000xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

CSV_FILE="${COINBASE_HEX}_rewards.csv"
DATABASE_FILE="state.sql"

read -r -d '' SQL_QUERY << EOM
SELECT   (layer/4032) epoch,
         layer,
         total_reward/1000000000.0 reward,
         hex(coinbase) address
FROM     rewards
WHERE    coinbase = X'${COINBASE_HEX}'
ORDER BY layer desc;
EOM

# Run the SQLite query in read-only mode and export the results to a CSV file
{
    echo ".mode csv"
    echo ".headers on"
    echo "$SQL_QUERY"
} | sqlite3 -readonly $DATABASE_FILE > $CSV_FILE

echo "The query results have been saved to $CSV_FILE"
