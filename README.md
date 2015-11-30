# Satellite Image Processing Environment

This is a [Vagrant](https://www.vagrantup.com) environment for processing satellite images. It can be used locally with [VirtualBox](https://www.virtualbox.org) or with [AWS EC2](https://aws.amazon.com/ec2/). Libraries installed include:

- [gdal](http://www.gdal.org) and python scripts for raster processing
- [landsat-util](https://github.com/developmentseed/landsat-util) for downloading and processing landsat 8 images
- [tl](https://github.com/mojodna/tl) and [tilelive](https://github.com/mapbox/tilelive) for copying tiles between sources. Includes tilelive modules:
  + [node-mbtiles](https://github.com/mapbox/node-mbtiles) for reading and writing mbtiles
  + [tilelive-omnivore](https://github.com/mapbox/tilelive-omnivore) for reading TIF and VRT files
  + [tilelive-http](https://github.com/mojodna/tilelive-http) for copying online map tiles
  + [tilelive-file](https://github.com/mapbox/tilelive-file) for reading/writing from/to the filesystem
- [mapbox-tile-copy](https://github.com/mapbox/mapbox-tile-copy) for creating tiles from local geodata files and uploading to s3

## Installation and Basic Usage

You will need to install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) to get started. Then clone this git repo and `cd` into the cloned folder:

```
git clone https://github.com/digidem/satellite-image-processing.git
cd satellite-image-processing
```

Then simply run `vagrant up` and sit back and wait as your machine is launched. Type `vagrant ssh` to connect to your machine and use gdal etc. The folder `/vagrant_data` is connected to the `./data` folder, for sharing files between the virtual machine and your local computer.

When you are done type `vagrant halt` to shutdown the virtual machine, or `vagrant destroy` to shutdown and remove all the guest hard drives. You can still `vagrant up` again, but it will take some time to download and install the machine again.

## Usage with AWS EC2

This is most useful when used with Amazon EC2, since bandwidth can be a limitation when downloading and uploading images locally. You will need an [Amazon AWS account](https://aws.amazon.com/free/) and you will need to install the [AWS CLI tool](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configure it with your credentials](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration)

Using EC2 requires certain security roles and groups to be set up first. You can use the helper scripts to do this for you:

```sh
./scripts/create_key_pair.sh
./scripts/create_s3_roles.sh
./scripts/create_security_group.sh
```

This will:

1. Create a keypair and save a private key (as `~/.ssh/satellite-image-processing.pem`)
2. Create an instance profile that allows you to write to your S3 buckets from your EC2 instance without credentials
3. Create a security policy group `ssh-only` that opens port 22 to allow ssh access to your instances

You will need to copy the example config:

```
cp ./config/aws.example.yml ./config/aws.yml && chmod 600 ./config/aws.yml
```
Edit `./config/aws.yml` to add your AWS access key ID and AWS secret access key. You can change the instance type you want to use here and any other settings.

Now you should be ready to simply `vagrant up` and sit back until everything is installed (should take about 5 minutes), then `vagrant ssh` to connect to your machine.

When you are done **do not forget** to `vagrant destroy` or your virtual machine will be left running and you will get a big bill at the end of the month!

## AWS Advanced Usage

You can launch additional instances for multiple processing tasks:

```
vagrant up --provider=aws instance-1
```

or you can launch several at once using a regular expression:

```
vagrant up --provider=aws /instance-[0-4]/
```

would launch 5 instances. Once you have launched multiple instances you will need to specify the instance name with any vagrant command e.g.

```
vagrant ssh instance-0
```

Don't forget to `vagrant destroy` to terminate all your instances when you are done.

## Example Processing Tasks

Here at [Digital Democracy](http://www.digital-democracy.org/) we often need to share satellite imagery with our partners. Often our partners don't have access to imagery processing tools or the training to use them, so we use this toolset to create composite images, pre-process or merge satellite imagery, or prepare tilesets or geotiffs for viewing offline.

- [Create a pansharpened natural color image from landsat 8](docs/pansharpened_landsat8_rgb.md)
