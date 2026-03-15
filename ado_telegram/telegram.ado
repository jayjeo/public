*! telegram.ado - Send "Code Run Completed" notification via Telegram
*! Version 1.1 - 2026-03-16
program define telegram
    version 14.0

    shell powershell -NoProfile -ExecutionPolicy Bypass -Command "& {                                                              ///
        $uri = 'https://api.telegram.org/bot7916530801:AAHcwzGRWqaBWgCx7Q-rS77mq2nvX_jDdrs/sendMessage';                          ///
        $body = @{ chat_id = '7791966761'; text = 'Code Run Completed' };                                                         ///
        Invoke-RestMethod -Uri $uri -Method Post -Body $body | Out-Null                                                            ///
    }"

    display as text "Telegram notification sent."
end
