# OpenDNS/Umbrella Security Scripts

These scripts can be used with OpenDNS/Umbrella enterprise account to help
manage API-related tasks - currently limited to adding, removing, and listing
domain blocks. You can leverage this with other scripts - such as
[phishing_catcher](https://github.com/x0rz/phishing_catcher) - to preemptively
block domains with new certificates. You may be duplicating efforts of
OpenDNS's "Newly Seen Domain" functionality (if you have that enabled), however
many of these sites already exist, but don't have SSL certs, so who really
knows if you're adding value. 

<b>Use at your own risk.</b>

blockSite.pl
------------
Makes API calls to Umbrella service to add/remove/list blocked sites for a
particular API integration. You need to have API enabled on your account and
you'll need to create an custom Integration and apply it to all applicable
policies.

<code> % ./blockSite.pl 
Usage: ./blockSite.pl [--add domain | --remove domain | --list]
</code>

processPhishes.pl
-----------------
Requirements: [phishing_catcher](https://github.com/x0rz/phishing_catcher) from
@x0rz, the above blockSite script.

You can use this script to process the logs for phishing_catcher and add them
to OpenDNS.
<br><br>
<b>Suggestion: Edit your catch_phishing.py script so it only logs really bad
issues, otherwise, you're going to be blocking potentially valid things, plus
your OpenDNS block list will become quickly even more unmanagable. The snippet
below shows bumped my score threshold up to 120.</b>

<pre>
            if score > 120:
                tqdm.tqdm.write(
                    "\033[91mSuspicious: "
                    "\033[4m{}\033[0m\033[91m (score={})\033[0m".format(domain,
                                                                        score))
                with open(log_suspicious, 'a') as f:
                    f.write("{}\n".format(domain))
            #elif score > 65:
            #    tqdm.tqdm.write(
            #                #        "Potential: "
            #                            #        "\033[4m{}\033[0m\033[0m
            #                            (score={})".format(domain, score))
            #
</pre>

Then run your script from your phishing_catcher directory once you have some
output:
<br>
<code> % cat suspicious_domains.log | ./processPhishes.pl
</code>

Cron this up - if you dare. 

OpenDNSUpdateCheck.sh
---------------------
Script to check a domain to see how long it takes for the block to become
effective.

<code>
$ ./OpenDNSUpdateCheck.sh
Usage: ./OpenDNSUpdateCheck.sh <domain to check>
</code>

Bugs/Contact Info
-----------------
Bug me on Twitter at [@brianwilson](http://twitter.com/brianwilson).
