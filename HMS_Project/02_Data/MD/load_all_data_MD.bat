@echo off
echo =======================================================
echo Loading Data for Manideep (MD)
echo Target DB: apps/apps@//150.136.96.10:1521/ebs_ebsdb
echo =======================================================

echo Loading HMS_HOSPITAL_MASTER_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_HOSPITAL_MASTER_MD.ctl log=HMS_HOSPITAL_MASTER_MD.log

echo Loading HMS_BRANCH_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_BRANCH_MD.ctl log=HMS_BRANCH_MD.log

echo Loading HMS_DEPT_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DEPT_MD.ctl log=HMS_DEPT_MD.log

echo Loading HMS_EMPLOYEE_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMPLOYEE_MD.ctl log=HMS_EMPLOYEE_MD.log

echo Loading HMS_EMP_PHONE_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMP_PHONE_MD.ctl log=HMS_EMP_PHONE_MD.log

echo Loading HMS_DOC_AVAIL_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DOC_AVAIL_MD.ctl log=HMS_DOC_AVAIL_MD.log

echo Loading HMS_PATIENT_MD...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_PATIENT_MD.ctl log=HMS_PATIENT_MD.log

echo All loads completed. Please review the .log files for any discarded/bad rows.
pause
