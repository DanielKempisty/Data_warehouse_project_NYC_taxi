| Column Name       | Data Type    | Description                                                        | Source                              | Transformations |
| ----------------- | ------------ | ------------------------------------------------------------------ | ----------------------------------- | --------------- |
| hvfhs_license_num | CHAR(6)      | License number of the High Volume For-Hire Service provider.       | bronze.td_license.hvfhs_license_num | Direct mapping. |
| app_company       | NVARCHAR(20) | Name of the application-based company operating under the license. | bronze.td_license.app_company       | Direct mapping. |
