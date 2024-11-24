<projekt>
Celem projektu będzie zbudowanie środowiska, które uruchomi aplikacje w środowisku Kubernetes, w tym
celu zostaną wykorzystane następujące narzędzia:
 - Docker - w celu zbudowania przynajmniej jednego obrazu samodzielnie, potrzebnego w projekcie
 - Terraform - w celu zarządzania infrastrukturą jako kod oraz uruchomieniem całego projektu
 - MiniKube/KinD - jako środowisko uruchomieniowe Kubernetes
 - Helm - sposób na tworzenie oraz wydawanie “paczek” w środowisku Kubernets
 
# Wymagania na ocenę 3.0 
 - Infrastruktura opisana w Terraformie
 - Aplikacja bez problemu uruchamia się poprzez wykonanie komendy: terraform apply
 - Minimalnie jeden obraz Docker zbudowany samemu
 - Na środoiwsku musi zostać wdrożona aplikacja wykorzystująca: Deployment / Pod / StatefulSet
 - Przynajmniej jedna aplikacja powinna wystawiać API lub apliakcję webową przy pomocy Ingress

# Wymagania na ocenę 3.5
 - Obraz dockerowy powinien być obrazem typu multi stage co za tym idzie musi składać się minimalnie z osobnego etapu budowania i osobnego środowiska uruchomienowego
 - Na środowisku musi zostać wdrożony przynajmniej jeden CronJob lub Job
 - Aplikacja musi mieć określone resources dla każdego kontenera 

# Wymagania na ocenę 4.0
 - wszystko co na ocenę 3.5
 - Aplikacja powinna pobierać zmienna środowiskową z Secret
 - Na środowisku Kubernetes muszą być wdrożone aplikacje typu: StatefulSet oraz Deployment
 - Aplikacje muszą być umieszczone w różnych namespace
 - Aplikacje muszą komunikować się ze soba wewnętrznie
 - Konfiguracja aplikacji powinna być brana z ConfigMap

# Wymagania na ocenę 4.5
 - Wszystko co na ocenę 4.0
 - Ingress musi mieć wystawiony certyfikat i serwować ruch przez HTTPS
 - Aplikacja typu StatefulSet musi używać PersistentVolume oraz PersistenVolumeClaim
 - Komenda terraform destroy powinna wykonywać się bez błędów w skończonym czasie
 - Przynajmniej jeden Helm Chart musi zostać wdrożony na środowisko przy pomocy Terraforma
 - Część zasobów musi być inicjalizowania w Terraform jako module

# Wymagania na ocenę 5.0
 - Wszystko co na ocenę 4.5
 - W pliku Terraform musi zostać zastosowany przynajmniej jeden konstrukt typu: for_each / count
 - zarówno w kontekście resource jak i w środku resource jako dynamic
 - Terraform musi wdrożyć samemu napisany Helm Chart składający się przynajmniej z 5 manifestów i
 - umożliwiający konfigurację go poprzez values
 - Przynajmniej jeden workload ( Deployment / StatefulSet ) mus się składać z initContainer oraz
 - minimalnie dwóch kontenerów w podzie
 - Przynajmniej jedna aplikacja musi się skalować przy pomocy HorizontalPodAutoscaler
</projekt>

