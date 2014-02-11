#!/bin/sh

VERSION=2.1.0

JOB_JAR=number-$VERSION-SNAPSHOT-job.jar
BITMAP_JAR=amino-accumulo-common-$VERSION-SNAPSHOT-job.jar
DIR_BASE=/amino/numbers

while getopts "b:d:j:" opt; do
  case $opt in
    b)
	echo "Setting Bitmap jar to $OPTARG"
	BITMAP_JAR=$OPTARG
	;;
    d)
	echo "Setting directory base to $OPTARG"
	DIR_BASE=$OPTARG
	;;
    j)
	echo "Setting Job jar to $OPTARG"
	JOB_JAR=$OPTARG
	;;
    v)
	echo "Setting version number to $OPTARG"
	VERSION=$OPTARG
	;;
    \?)
	echo "Invalid option -$OPTARG" >&2
	exit 1
	;;
  esac
done

echo "JOB JAR set to $JOB_JAR"
echo "Bitmap JAR set to $BITMAP_JAR"
echo "Directory base set to $DIR_BASE"
echo "Version $VERSION"

hadoop jar $JOB_JAR com._42six.amino.api.framework.FrameworkDriver --amino_default_config_path $DIR_BASE/config &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.DatabasePrepJob $DIR_BASE/out $DIR_BASE/config &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.ByBucketJob $DIR_BASE/out $DIR_BASE/config $DIR_BASE/working &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.BitLookupJob $DIR_BASE/out $DIR_BASE/config $DIR_BASE/working &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.StatsJob $DIR_BASE/out $DIR_BASE/config &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.HypothesisJob $DIR_BASE/out $DIR_BASE/config $DIR_BASE/working &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.reverse.ReverseBitmapJob $DIR_BASE/out $DIR_BASE/config &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.reverse.ReverseFeatureLookupJob $DIR_BASE/out $DIR_BASE/config $DIR_BASE/working &&
hadoop jar $BITMAP_JAR com._42six.amino.bitmap.FeatureMetadataJob $DIR_BASE/config

