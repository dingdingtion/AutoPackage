


######
#  将 AutoPackage 放置与 project 文件同级 
#  使用命令行 sh AutoPackage.sh 运行
#
#############################

echo "***************  基础环境配置  ********************************"

#######################仅在此处需要配置#######################
# 指定要打包编译的方式 : Release,Debug...
configuration_name='Release'

# xcworkspace:true; xcodeproj:false
is_workspace="true"

###########################################################

# 脚本路径
scriptPath=$(cd `dirname $0`; pwd)


echo "请选择打包方式(输入序号,按回车即可)"
echo "1. AdHoc"
echo "2. AppStore"
echo "3. Development"

#获取用户输入的内容
read inputParagram

# 用于 -exportOptionsPlist <plistpath> 的配置
exportOptionsPlist=""

#注意 if 的格式 括号间要有空格
#获取打包方式对应的plist文件
if [ "${inputParagram}" -eq "1" ]; then

	exportOptionsPlist=""$scriptPath"/AdHocPlist.plist"

elif [ "${inputParagram}" -eq "2" ]; then

	exportOptionsPlist=""$scriptPath"/AppStorePlist.plist"

elif [ "${inputParagram}" -eq "3" ]; then

	exportOptionsPlist=""$scriptPath"/DevelopmentPlist.plist"

fi


#进入当前工程目录
cd ..

echo "进入目录： $(cd `dirname $0`; pwd)"

# 基础参数获取
# 工程名称 workspace 或 project 的名字
# ./BDLifeManageProject.xcodeproj -> BDLifeManageProject
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

# 工程 scheme 名称 （一般情况 scheme 和 project 的名称一致）
scheme_name=${project_name}

# 指定输出ipa路径
export_path=~/Desktop/$project_name-AutoPackage

# 指定输出归档文件地址
xcarchivepath="$export_path/$project_name.xcarchive"


echo "***************  开始构建工程  ********************************"


if [[ -d "$export_path" ]]; then
	# 删除存在的xcarchive文件
    rm -rf $export_path/$project_name.xcarchive
else
	mkdir -pv $export_path
fi


# 开始使用 xcodebuild 进行项目构建
if [[ $is_workspace ]]; then

xcodebuild -workspace ${project_name}.xcworkspace \
		   -scheme ${scheme_name} \
		   -configuration ${configuration_name}
		   clean

xcodebuild  -workspace ${project_name}.xcworkspace \
 		    -scheme $scheme_name  \
 		    -configuration $configuration_name \
 		    -archivePath ${xcarchivepath} \
 		    archive

else
xcodebuild -scheme $scheme_name
		   -configuration $configuration_name
		   clean
		   
xcodebuild  -scheme $scheme_name 
 		    -configuration $configuration_name
 		    -archivePath ${xcarchivepath}
 		    archive
fi


if [[ -d "$xcarchivepath" ]]; then
	echo "项目构建成功, 开始导出ipa"
else
		echo "项目构建失败"

	exit 1
fi


echo "***************  导出 ipa  ********************************"


xcodebuild -exportArchive -archivePath ${xcarchivepath} \
                           -exportPath  ${export_path} \
                           -exportOptionsPlist ${exportOptionsPlist}


open $export_path

