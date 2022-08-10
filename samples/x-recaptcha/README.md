# Summary
* Use the Apigee API proxy definitions (in XML) to enable reCAPTCHA in your API request flow
* Be sure to first [choose the appropriate reCAPTCHA key type](https://cloud.google.com/recaptcha-enterprise/docs/choose-key-type)
* As well, [create a reCAPTCHA key](https://cloud.google.com/recaptcha-enterprise/docs/create-key) to use with Apigee X

# Explanation of Proxy Definitions
1. [recaptcha.xml](./recaptcha.xml)
   * The parent proxy definition
   * The other proxy definitions in this example are referenced from this parent proxy
2. policies/[Call-reCAPTCHA.xml](./policies/Call-reCAPTCHA.xml)
   * Initiates the reCAPTCHA handshake with a POST request
3. policies/[Extract-Token.xml](./policies/Extract-Token.xml)
   * Extracts the reCAPTCHA token value into a variable, for use by other Apigee proxies
4. policies/[Set-Response.xml](./policies/Set-Response.xml)
   * Capture the response from the reCAPTCHA authorization process
5. proxies/[default.xml](./proxies/default.xml)
   * API endpoint where initial requests are made for reCAPTCHA authentication (authn)
   * Entrypoint for the whole request flow
6. targets/[default.xml](./targets/default.xml)
   * Backend target URL