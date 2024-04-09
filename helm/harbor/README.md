# Useful information

## Default admin Harbor credentials

Username: admin
Password: Harbor12345

## Changes to values.yaml

    Ingress host core:

    ```yaml
    ingress:
      hosts:
        core: registry.nginx-app.info
    ```

    Ingress class name:

    ```yaml
    className: "nginx"
    ```

    Annotation additions for for default nginx ingress controller:

    ```yaml
      nginx.org/client-max-body-size: "0"
    ```

    Harbor is deployed behind the proxy, set it as the URL of proxy:

    ```yaml
    externalURL: https://registry.nginx-app.info
    ```
