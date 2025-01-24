#!/bin/bash

# Create timestamp
TIMESTAMP=$(date +%Y%m%d)

# Schema migrations
mv tables/001_create_users_table.sql schema/001_${TIMESTAMP}_create_users_table.sql
mv tables/002_create_teams_tables.sql schema/002_${TIMESTAMP}_create_teams_tables.sql
mv tables/003_create_cases_and_related_tables.sql schema/003_${TIMESTAMP}_create_cases_and_related_tables.sql
mv tables/004_create_notes_messages_attachments_feedback.sql schema/004_${TIMESTAMP}_create_notes_messages_attachments_feedback.sql

# Rename policy files
for f in policies/*.sql; do
    if [[ $f != *"test_"* ]]; then
        NEW_NAME=$(echo $f | sed "s/policies\/\([0-9]*\)_/policies\/\1_${TIMESTAMP}_/")
        mv "$f" "$NEW_NAME"
    fi
done

# Create revert scripts
for f in schema/*.sql; do
    BASE=$(basename $f)
    NUMBER=$(echo $BASE | cut -d'_' -f1)
    REVERT_NAME="revert/${NUMBER}_${TIMESTAMP}_revert_$(echo $BASE | cut -d'_' -f4-)"
    echo "-- Revert script for $BASE" > "$REVERT_NAME"
    echo "BEGIN;" >> "$REVERT_NAME"
    echo "-- Add revert commands here" >> "$REVERT_NAME"
    echo "ROLLBACK;" >> "$REVERT_NAME"
done

# Create master migration script
echo "-- Master migration script" > master_migration.sql
echo "-- Generated on $(date)" >> master_migration.sql
echo "" >> master_migration.sql

# Add schema migrations
echo "-- Schema migrations" >> master_migration.sql
for f in schema/*.sql; do
    echo "\i $f" >> master_migration.sql
done

# Add function migrations
echo "" >> master_migration.sql
echo "-- Function migrations" >> master_migration.sql
for f in functions/*.sql; do
    echo "\i $f" >> master_migration.sql
done

# Add trigger migrations
echo "" >> master_migration.sql
echo "-- Trigger migrations" >> master_migration.sql
for f in triggers/*.sql; do
    echo "\i $f" >> master_migration.sql
done

# Add policy migrations
echo "" >> master_migration.sql
echo "-- Policy migrations" >> master_migration.sql
for f in policies/*.sql; do
    if [[ $f != *"test_"* ]]; then
        echo "\i $f" >> master_migration.sql
    fi
done

# Add performance migrations
echo "" >> master_migration.sql
echo "-- Performance migrations" >> master_migration.sql
for f in performance/*.sql; do
    echo "\i $f" >> master_migration.sql
done

echo "Migration files reorganized successfully!" 