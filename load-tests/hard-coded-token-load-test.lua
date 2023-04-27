wrk.method = "POST"

-- post form urlencoded data
wrk.body = "x=[0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0]" -- Cualquier vector de 1s y 0s con este tamaño funciona
wrk.headers['Authorization'] = "bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImM5YWZkYTM2ODJlYmYwOWViMzA1NWMxYzRiZDM5Yjc1MWZiZjgxOTUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzMjU1NTk0MDU1OS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjMyNTU1OTQwNTU5LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTAxNjQ3NTQwMDMzOTgwNTIyMTM3IiwiZW1haWwiOiJhbGVqYW5kcm9hcmlhc3p1bHVhZ2FAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJYejBwdzJ1c0oxTEVOT0E0SWJDV2NRIiwiaWF0IjoxNjgyNTU5NTA4LCJleHAiOjE2ODI1NjMxMDh9.FJ_eLy7BH_lH5HHFA2mTwBrJ7kvU8SayD_SQnUSNCOSiSV276etHHin5CatzPVBr_aFMezFIPsPCnW2X5Pap_b-xVXT_rRpaegI8jos6kg0rxArBX8wSu9M8v-O7IewpPYVIQAiL-G-TDJ2YUenqdrcGRSoS27ExeqtfetaJt4r--7bPHcC03X57OaVgItzzZ3M0SCL4gNW8KQvpKfZWsEQcXjleP6mjI3I0wx9BUO7sBBvUrt3nrQOowDwDbpengtBrdJgCwVsTrOPb9ymDiZEqtpjh2_z1CBO9B24Dks28Ia-Agb6IABA52JyW-iD49nsJeDqELHSCnXIdzJt1_A" -- Reemplazar token
wrk.headers['Content-Type'] = "application/json"
