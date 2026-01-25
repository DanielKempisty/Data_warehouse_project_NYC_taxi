| Column Name       | Data Type    | Description                    | Source            | Transformations |
| ----------------- | ------------ | ------------------------------ | ----------------- | --------------- |
| hvfhs_license_num | CHAR(6)      | FHV high-volume license number | bronze.td_license | Direct load     |
| app_company       | NVARCHAR(20) | Application company name       | bronze.td_license | Direct load     |
