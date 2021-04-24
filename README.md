# PostgreSQL
The exercise request some additional constraints and enhancements:

Proposal:
1. Create REGEX that validates domain_name.
2. 'Registered' date should be between date of oldest record and NOW(), unless you can register with future date.
3. domain_flag table should only accept domain flags from domains, that are in domain table.
4. domain_flag table should only accept flags, whose effective_range is subset of registered-unregistered range.

Question about the exercise:
"do not have and active (valid) expiration (``EXPIRED``) flag." - 
  - Its not clear to me, if "active (valid) flag" means the flag exists or if it is set to TRUE.
  - In my opinion, it can be interpreted in two ways: 
  	1. Active flag can be TRUE or FALSE, as long as it has defined state within given range, we call it "Active(valid) flag"
  	2. Active flag means it is set to TRUE
  I assumed the 1. is true, but if not, it can easily be repaired by adding "value = TRUE" next to the flag selection
 
"return fully qualified domain name" - Isnt domain name fully qualified by itself ?
