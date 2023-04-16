

# kernel 4.19
make  CLANG_TRIPLE=../prebuilt/toolchain/aarch64/bin/aarch64-cros-linux-gnu- CC=../prebuilt/toolchain/aarch64/bin/aarch64-cros-linux-gnu-clang CROSS_COMPILE=../prebuilt/toolchain/aarch64/bin/aarch64-cros-linux-gnu- ARCH=arm64 korlan-bx_defconfig CONFIG_DEBUG_SECTION_MISMATCH=y menuconfig


# patch
https://eureka-partner-review.googlesource.com/c/amlogic/kernel/+/258568/2/arch/arm64/configs/korlan-p2_defconfig
# 第一种方式
## 实现 aplay 和 uac 同时播放冲突问题
- issues：https://partnerissuetracker.corp.google.com/issues/262352934#comment4
 - 修复的 cl: https://eureka-partner-review.googlesource.com/c/amlogic/kernel/+/275167


## 迁移 tdm_bridge 功能到 kernel 5.4

### AV400 buildroot 测试 UAC

https://scgit.amlogic.com/293851

### AV400 kernel-5.4 打开 UAC

https://scgit.amlogic.com/#/c/293855/

### 修改 功放板 patch

Change power amplifier driver board from D622 to D613

https://scgit.amlogic.com/#/c/292999/

#### 修改 UAC 模式支持 window

https://scgit.amlogic.com/29845

### 最终迁移完成 patch

https://scgit.amlogic.com/295257

### 添加 timestamp 和 usb notify 给 u_audio.c

 https://scgit.amlogic.com/300119

 由于 crg 没有 sof 数据包，所以暂时只能在连接的时候插入时间戳，无法在 sof 包加时间戳。

### 解决 av400 找不到 tas5707 codec 的问题

```c
  static int soc_bind_dai_link(struct snd_soc_card *card,
          struct snd_soc_dai_link *dai_link)
		  
 for_each_link_codecs(dai_link, i, codec) {
		  rtd->codec_dais[i] = snd_soc_find_dai(codec);
		  if (!rtd->codec_dais[i]) {
				  dev_info(card->dev, "ASoC: CODEC DAI %s not registered\n",
						   codec->dai_name);
				  goto _err_defer;		  
  } else {                                                                                                                                                                                                                                    
		  if (!strcmp(codec->dai_name, "tas5707")) {
				  printk("lsken00 %s, codec_dainame:%s\n", __func__, codec->dai_name);
				  printk("lsken00 ------- 0x%p", card);
		  }    
  }    

//############## 参考上面

static struct snd_soc_dai *aml_get_dai_name_from_link(struct snd_soc_card *card,
		struct snd_soc_dai_link *dai_link, const char *card_dai_name)
{
	struct snd_soc_dai_link_component *codec;
	struct snd_soc_dai *card_dai;
	int i;

	for_each_link_codecs(dai_link, i, codec) {
		card_dai =  snd_soc_find_dai(codec);
		if(card_dai && !strcmp(codec->dai_name, card_dai_name)) {
			printk(" %s, codec_dainame:%s\n", __func__, codec->dai_name);
			return card_dai;
		}
	}
	return NULL;
}

static struct snd_soc_dai *aml_soc_card_get_dai(struct snd_soc_card *card,
		const char *card_dai_name)
{
	int i;
	struct snd_soc_dai *ret_dai;
	struct snd_soc_dai_link *dai_link;
	for_each_card_prelinks(card, i, dai_link) {
		ret_dai = aml_get_dai_name_from_link(card, dai_link, card_dai_name);
		if (ret_dai)
			return ret_dai;
	}
	return NULL;
}
```

### 解决 aml_gpio_mute_spk 问题

> FIx: error: aml_gpio_mute_spk (aml_card_priv) in aml_tdm_br_tdm_start

```sh
--- a/sound/soc/amlogic/auge/card.c
+++ b/sound/soc/amlogic/auge/card.c
@@ -1180,6 +1182,7 @@ static int aml_card_parse_of(struct device_node *node,
                goto card_parse_end;
 
        ret = aml_card_parse_aux_devs(node, priv);
+       aml_card_priv = priv;
 
 card_parse_end:
```

### 解决 tdm_bridge underrun 问题

#### 声音播放延迟问题

**clock 参数文档可以查看** `Meson\A5\appNote\A5_clk_tree.xlsx`

这个判断回和 channel 有关，

```c
a5 tx_mask must be 0x03 aml_tdm_br_hw_setting(tdm, 2);  //a5 ch = 2

korlan ch = 1
```

####  src-clk-freq 不对导致偶尔会出现 underrun 问题

tdm_bridge 偶尔会出现 underrun 问题，肯定是和 clk 有关，对应的代码

```c
//aml_tdm_platform_probe
ret = of_property_read_u32(dev->of_node, "src-clk-freq", &p_tdm->syssrc_clk_rate);

//mclk 和 clk 的值不同芯片不一样
clk_set_rate(tdm->mclk, mclk);  // 对应设备树种的 src-clk-freq，
// a5 491520000 a1 614400000

clk_set_rate(tdm->clk, mpll_freq);  //从 seeting->sysclk 中过来
```

- 修改设备树

```sh
--- a/arch/arm64/boot/dts/amlogic/a5_a113x2_av400_1g_spk.dts
+++ b/arch/arm64/boot/dts/amlogic/a5_a113x2_av400_1g_spk.dts
@@ -508,7 +508,7 @@
                start_clk_enable = <1>;
                tdm5v-supply = <&vcc5v_reg>;
                tdm3v3-supply = <&vddio3v3_reg>;
-               src-clk-freq = <614400000>;
+               src-clk-freq = <491520000>; /*mpll1 mclk is 491520000*/
                status = "okay";
        };
```

#### 如果有一点点杂音

那可能是与 aml_frddr_set_fifos 或者 dma_buf->bytes 设置不对有关。


### 添加 timestamp 模块

- 修改dts

```sh
                channel_mask = <0x3>;
                status = "disabled";
        };
+       timestamp {
+               compatible = "amlogic, meson-soc-timestamp";
+               reg = <0x0 0xFE0100EC 0x0 0x8>;
+               status = "okay";
+       };
 }; /* end of audiobus */


+CONFIG_AMLOGIC_SOC_TIMESTAMP=y
```

- 修改 Kconfig 和 Makefile

```sh
diff --git a/drivers/amlogic/Kconfig b/drivers/amlogic/Kconfig
index 3208df21ec95..5daaa5be6709 100644
--- a/drivers/amlogic/Kconfig
+++ b/drivers/amlogic/Kconfig
@@ -177,6 +177,7 @@ source "drivers/amlogic/freertos/Kconfig"
 
 source "drivers/amlogic/aes_hwkey_gcm/Kconfig"
 source "drivers/amlogic/gpio/Kconfig"
+source "drivers/amlogic/timestamp/Kconfig"
 
 endmenu
 endif
diff --git a/drivers/amlogic/Makefile b/drivers/amlogic/Makefile
index 6226bc7b43b3..fba5e8d7b264 100644
--- a/drivers/amlogic/Makefile
+++ b/drivers/amlogic/Makefile
@@ -39,6 +39,7 @@ obj-$(CONFIG_AMLOGIC_MKL)             += mkl/
 
 #Always build in code/modules
 obj-$(CONFIG_AMLOGIC_CPUIDLE)          += cpuidle/
+obj-$(CONFIG_AMLOGIC_SOC_TIMESTAMP) += timestamp/
 obj-$(CONFIG_AMLOGIC_DEFENDKEY)                += defendkey/
 obj-$(CONFIG_AMLOGIC_AUTO_CAPTURE)     += free_reserved/
 obj-$(CONFIG_AMLOGIC_GX_SUSPEND)       += pm/
diff --git a/drivers/amlogic/timestamp/Kconfig b/drivers/amlogic/timestamp/Kconfig
new file mode 100644
index 000000000000..488faae454a2
--- /dev/null
+++ b/drivers/amlogic/timestamp/Kconfig
@@ -0,0 +1,8 @@
+# SPDX-License-Identifier: GPL-2.0-only
+config AMLOGIC_SOC_TIMESTAMP
+       bool "Amlogic SoC Timestamp"
+       depends on ARCH_MESON || COMPILE_TEST
+       depends on OF
+       default y
+       help
+         Say yes if you want to get soc-level timestamp.
```

- 从 kernel 5.15 拷贝 drivers/amlogic/timestamp

### Fix: aml_tdm_bridge_frddr_isr, timestamp buffer overrun

timestamp overrun Fix 总结：需要用户层一直读时间戳，才不会出现读写不同步，否则需要设置 static int save_ts = 0

```sh
#!/usr/bin/sh
while true
do
        cat /proc/tdm_tsb | tail -1 > /tmp/1.txt
        sleep 0.1
done
```

**注意**：aml_frddr_set_intrpt 设置不会影响 tdm_bridge underrrun , 只会影响 timestamp overrun 。

### 在 buildroot 中添加启动 UAC 声卡的脚本

```sh
touch S90start_adb.sh
vim S90start_adb.sh
chmod 777 S90start_adb.sh
```

然后在 S90start_adb.sh 中天添加需要执行的命令，比如

```sh
# AV400
rmmod sdio_bt
rmmod vlsicomm

mount -t configfs configfs /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/amlogic
echo 0x18D1 > /sys/kernel/config/usb_gadget/amlogic/idVendor  # window 0x18D12
echo 0x4e26 > /sys/kernel/config/usb_gadget/amlogic/idProduct
mkdir /sys/kernel/config/usb_gadget/amlogic/strings/0x409
echo '0123456789ABCDEF' > /sys/kernel/config/usb_gadget/amlogic/strings/0x409/serialnumber
echo amlogic > /sys/kernel/config/usb_gadget/amlogic/strings/0x409/manufacturer
echo korlan > /sys/kernel/config/usb_gadget/amlogic/strings/0x409/product
mkdir -p  /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/strings/0x409

mkdir /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/strings/0x401
echo "uac2" > /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/strings/0x401/configuration
mkdir /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0
echo 0x1 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/c_chmask  # 0x03 是两个通道
echo 48000 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/c_srate
echo 4 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/c_ssize
echo 0x1  > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/p_chmask
echo 48000 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/p_srate
echo 4 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/p_ssize
ln -s /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0 /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/uac2.0


echo "config ADB"
echo adb > /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/amlogic/functions/ffs.adb
mkdir -p /dev/usb-ffs/adb
mount -t functionfs adb /dev/usb-ffs/adb
killall adbd  
ln -s /sys/kernel/config/usb_gadget/amlogic/functions/ffs.adb /sys/kernel/config/usb_gadget/amlogic/configs/amlogic.1/ffs.adb
/usr/bin/adbd &

sleep 3

echo "" > /sys/kernel/config/usb_gadget/amlogic/UDC  
echo "fdd00000.crgudc2" > /sys/kernel/config/usb_gadget/amlogic/UDC 

arecord -l 
```

### 解决 EQDRC 导致 uac 播放结束后 aplay 没声音问题

jira: https://jira.amlogic.com/browse/SWPL-118631

分析

- EQDRC（aed） 默认提供给 TDMOUT_B  使用， 开启 tdm_bridge 后 aed 绑定了 frddr_B ，这个时候 aplay 通过 tdm 播放，使用的是 frddr_C ，tdm 在进行 aml_aed_enable 时，使用的却是 frddr_B ， 而且 aml_aed_enable 在 aml_frddr_enable 之前，所以 frddr_B 会一直往 TDMOUT_B 中送数据，占用这 TDMOUT_B ，而这时候 frddr_B 是没有数据的（因为 uac 没播放），所以 frddr_c 的数据送不到 TDMOUT_B , 就没有声音。

![](https://cdn.staticaly.com/gh/kendall-cpp/blogPic@main/blog-01/audio-EQ_DRC_frddr.243vj7g3q97k.webp)

```c
// dts 设置了 aed 默认提供给 frddr_b 使用
eqdrc_module = <1>;

// aed 绑定 frddr 的代码
struct frddr *fr = fetch_frddr_by_src(p_attach_aed->attach_module);

if (frddrs[i].in_use && frddrs[i].dest == frddr_src)
        return &frddrs[i];

fr->dest = dst;  
// dest 来自 aml_frddr_select_dst(struct frddr *fr, enum frddr_dest dst)
//switch (p_tdm->id) --> case 1:dst = TDMOUT_B;

frddr_src;
//p_attach_aed->attach_module
//static void aml_aed_enable(struct frddr_attach *p_attach_aed, bool enable)
void aml_aed_top_enable(struct frddr *fr, bool enable) {
        if (aml_check_aed_module(fr->dest))
                aml_aed_enable(&attach_aed, enable);
}
void aml_set_aed(bool enable, int aed_module) {
        attach_aed.attach_module = aed_module;
}
static void effect_init(struct platform_device *pdev) {
        aml_set_aed(1, p_effect->effect_module);
}
static int effect_platform_probe(struct platform_device *pdev) {
        dev_set_drvdata(&pdev->dev, p_effect);  // 实际就是 pdev->dev = p_effect
        effect_init(pdev);
}

// aml_aed_enable 中更新 FRDDR bit 的代码、
aml_audiobus_update_bits(actrl, reg, 0x1 << 3, enable << 3);
```

### 解决由于 c_ssize 设置成 2 导致 underrun 问题

- c_ssize = 2 表示 rate 96k
- c_ssize = 4 表示 rate 48k

从 log 中可以看出

```
tdm_bridge underrun
aml_tdm_br_tdm_start playing, tdm_cached_data:960   // 这里应该是 1920
```

Fix 方案

```sh
echo 48000 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/c_srate
echo 4 > /sys/kernel/config/usb_gadget/amlogic/functions/uac2.0/c_ssize
```

#### uac 模式

对应代码路径： drivers/usb/gadget/function/f_uac2.c 

- USB_ENDPOINT_SYNC_ASYNC

- USB_ENDPOINT_SYNC_ADAPTIVE

- USB_ENDPOINT_SYNC_SYNC

![](https://jsd.cdn.zzko.cn/gh/kendall-cpp/blogPic@main/blog-01/usb_enopint_mode.1ln58gbfssv4.webp)


添加 ubuntu 和 win uac mode

> https://scgit.amlogic.com/#/c/298458


### dam 音频数据

查看 USB 传到 tdm_bridge 的数据是否有问题


或者 ： > A5-file\av400\tdm_bridge_dump_dam_2_wavfile.patch 

### 添加 HIFIPLL

需要在 dts 中配置这个寄存器 ANACTRL_HIFIPLL_CTRL0 0xfe008100

```c
audio_tdm_bridge: tdm_bridge {
        compatible = "amlogic, snd-tdm-bridge";                                                       
        reg = <0x0 0xfe008100 0x0 0x10>;
        status = "okay";
}; 
```

## A4 上跑 tdb_bridge

- cl topic: https://scgit.amlogic.com/#/q/status:open+project:kernel/common+branch:bringup/amlogic-5.4/A4_2_20230309+topic:SWPL-116372

