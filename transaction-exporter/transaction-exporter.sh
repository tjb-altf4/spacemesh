#!/bin/bash
# spacemesh transaction exporter
# note: rewards included in transactions

# coinbase is provided in bech32 format (sm1qqqqq)), this must be converted to hex for this script
# decode bech32 to hex using https://slowli.github.io/bech32-buffer/

COINBASE_HEX=00000000xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

CSV_FILE="${COINBASE_HEX}_transactions.csv"
DATABASE_FILE="state.sql"

read -r -d '' SQL_QUERY << EOM
SELECT   (layer_updated/4032) epoch,
         layer_updated layer,
         balance/1000000000.0 balance,
         COALESCE(balance/1000000000.0 - LAG(balance/1000000000.0) OVER (ORDER BY layer_updated), balance/1000000000.0) tx,
         hex(address) address
FROM     accounts
WHERE    address = X'${COINBASE_HEX}'
ORDER BY layer;
EOM

# Run the SQLite query in read-only mode and export the results to a CSV file
{
    echo ".mode csv"
    echo ".headers on"
    echo "$SQL_QUERY"
} | sqlite3 -readonly $DATABASE_FILE > $CSV_FILE

echo "The query results have been saved to $CSV_FILE"
