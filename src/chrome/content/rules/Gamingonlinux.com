<ruleset name="Gamingonlinux.com">
  <target host="gamingonlinux.com" />
  <target host="www.gamingonlinux.com" />

  <rule from="^http://(www\.)?gamingonlinux\.com/" to="https://www.gamingonlinux.com/" />
</ruleset>
