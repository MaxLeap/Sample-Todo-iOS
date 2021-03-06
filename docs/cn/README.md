# Sample-Todo-iOS

## 介绍

这个项目介绍如何使用 MaxLeap 实现用户注册和登陆，以及如何展示一个列表，并向其中添加或者删除元素。

## 演示功能

- 用户注册
- 用户登陆
- 创建 MLObject，创建 Todo List
- 在表(Class)之间建立关系，关联 Item 到一个 Todo List
- 更新 MLObject，将 Item 标记为已完成
- 查询 MLObject，查询用户自己创建的 Todo List 以及与 List 相关联的 Items
- 删除 MLObject，删除 Todo List 以及 Item

## 效果截图

![](../images/1.png)
![](../images/2.png)
![](../images/3.png)

## 如何运行

- 克隆这个仓库，然后打开项目
- 在 [MaxLeap 开发者控制台](https://maxleap.cn) 中创建一个应用，下面称他为 MaxLeap 应用。如果已经创建，跳过这个步骤。
- 在 `AppDelegate.` 中填写 MaxLeap 应用的 applicationId 和 clientKey，并根据应用地区选择 `site` (`MLSiteUS`, `MLSiteCN`).
- 按下 <kbd>Commond</kbd> + <kbd>R</kbd> 按钮运行

## 了解更多

详细信息请查看官方 [MaxLeap iOS 开发指南](https://maxleap.cn/zh_cn/guide/devguide/ios.html);
