<!--
 * @Author: xiongsheng
 * @Date: 2021-12-19 11:22:34
 * @LastEditors: xiongsheng
 * @LastEditTime: 2021-12-19 14:45:01
 * @Description: 
-->
## 整体参考 https://keysaim.github.io/post/blog/deploy-hugo-blog-in-github.io/
checkout 命令 git clone git@github.com:huoyanwuzhe629/blogs.git qianyangBlog --recursive
（因为有git submodule 所以得用--recursive）
## 依赖项
hugo 版本 0.42.2
jane主题 hugo版本不可升级，会导致主页为空，有不兼容更新，从https://github.com/gohugoio/hugo/releases寻找对应版本

## 项目文件结构
1. blogs/content中为源码，编辑后使用hugo server可预览
2. 执行hugo命令，编译文件，存放于public目录中，public目录连接到github page仓库，提交即部署
