> 

U-Boot官网:`https://docs.u-boot.org/en/latest/`

u-boot启动流程

- 板子上电以后，首先执行的是ROM中的一段启动代码。启动代码**根据寄存器/外部管脚配置**，确定是进入下载模式，还是从某介质(Flash/EMMC/SD卡等存储设备)启动u-boot

> ROM中的代码是固化的，无法修改

# 一、介绍

> FDT，flatted device tree，扁平设备树，简单来说，就是将部分设备信息结构存放到device tree文件中。
>
> uboot最终将其编译成dtb文件，使用过程中通过解析该dtb来获取板级设备信息。  

> U-boot的dtb和kernel中的dtb是一致的，有关fdt的详细介绍，参考doc/README.fdt-control

### dtb在U-boot中的位置

- dtb能够以两种形式编译到U-boot的镜像中

1. dtb和u-boot的bin文件分离(imx6q中使用的这种方式，在.config文件中可以查看到)

> 通过CONFIG_OF_SEPARATE宏定义使能，dtb最后会追加到u-boot的bin文件的最后面，通过u-boot的结束地址符号_end符号来获取dtb的地址

1. dtb集成到u-boot的bin文件内部

> 通过CONFIG_OF_EMBED宏定义使能，dtb会位于u-boot的.dtb.init.rodata段中，通过__dtb_dt_begin符号来获取dtb

1. 获取dts文件的地址gd->fdt_blob

```
// 宏用来表示是否把dtb文件放在uboot.bin的文件中
CONFIG_OF_EMBED

// 单独编译dtb文件
CONFIG_OF_SEPARATE，编译出来的dtb放在uboot.bin的最后面，就是dtb追加到uboot的bin文件后面时，通过_end符号来获取dtb地址

gd->fdt_blob = (ulong *)&_end;

// 可以通过fdtcontroladdr环境变量来指定fdt的地址
gd->fdt_blob = (void *)getenv_ulong("fdtcontroladdr", 16,
						(uintptr_t)gd->fdt_blob); 
```

###  dtb解析接口

- 定义在lib/fdtdec.c文件中，节点变量node中存放的是偏移地址

```
// 获得dtb下某个节点的路径path的偏移，偏移就代表这个节点
int fdt_path_offset(const void *fdt, const char *path)
eg：node = fdt_path_offset(gd->fdt_blob, “/aliases”);

// 获得节点node的某个字符串属性值
const void *fdt_getprop(const void *fdt, int nodeoffset, const char *name, int *lenp)
eg： mac = fdt_getprop(gd->fdt_blob, node, “mac-address”, &len);

// 获得节点node的某个整形数组属性值
int fdtdec_get_int_array(const void *blob, int node, const char *prop_name, u32 *array, int count)
eg： ret = fdtdec_get_int_array(blob, node, “interrupts”, cell, ARRAY_SIZE(cell));

// 获得节点node的地址属性值
fdt_addr_t fdtdec_get_addr(const void *blob, int node, const char *prop_name)
eg：fdtdec_get_addr(blob, node, “reg”);

// 获得config节点下的整形属性、bool属性、字符串等等
fdtdec_get_config_int、fdtdec_get_config_bool、fdtdec_get_config_string

// 获得chosen下的name节点的偏移
int fdtdec_get_chosen_node(const void *blob, const char *name)

// 获得chosen下name属性的值
const char *fdtdec_get_chosen_prop(const void *blob, const char *name)
```

- 定义在lib/fdtdec_common.c文件中

```
// 获得节点node的某个整形属性值
int fdtdec_get_int(const void *blob, int node, const char *prop_name, int default_val)
eg： bus->udelay = fdtdec_get_int(blob, node, “i2c-gpio,delay-us”, DEFAULT_UDELAY);

// 获得节点node的某个无符号整形属性值
fdtdec_get_uint
```

## fdt 命令

对于u-boot提供了fdt的相关命令

```
fdt - flattened device tree utility commands

Usage:
fdt addr [-c]  <addr> [<length>]   - Set the [control] fdt location to <addr>
fdt apply <addr>                    - Apply overlay to the DT
fdt move   <fdt> <newaddr> <length> - Copy the fdt to <addr> and make it active
fdt resize [<extrasize>]            - Resize fdt to size + padding to 4k addr + some optional <extrasize> if needed
fdt print  <path> [<prop>]          - Recursive print starting at <path>
fdt list   <path> [<prop>]          - Print one level starting at <path>
fdt get value <var> <path> <prop>   - Get <property> and store in <var>
fdt get name <var> <path> <index>   - Get name of node <index> and store in <var>
fdt get addr <var> <path> <prop>    - Get start address of <property> and store in <var>
fdt get size <var> <path> [<prop>]  - Get size of [<property>] or num nodes and store in <var>
fdt set    <path> <prop> [<val>]    - Set <property> [to <val>]
fdt mknode <path> <node>            - Create a new node after <path>
fdt rm     <path> [<prop>]          - Delete the node or <property>
fdt header                          - Display header info
fdt bootcpu <id>                    - Set boot cpuid
fdt memory <addr> <size>            - Add/Update memory node
fdt rsvmem print                    - Show current mem reserves
fdt rsvmem add <addr> <size>        - Add a mem reserve
fdt rsvmem delete <index>           - Delete a mem reserves
fdt chosen [<start> <end>]          - Add/update the /chosen branch in the tree
                                        <start>/<end> - initrd start/end addr
NOTE: Dereference aliases by omitting the leading '/', e.g. fdt print ethernet0.
```

fdt print加path参数，则打path内容，如下(其中/memory是path)：

```c
U-Boot> fdt print /memory
memory {
device_type = "memory";
reg = <0x70000000 0x4000000>;
};

U-Boot> fdt print #不加参数时，打印出整颗树
```



二、u-boot 获取GPT分区表

在uboot中通过命令打印分区表

```
part list mmc 0
```

3588-android-uboot

```c
#include <common.h>
#include <command.h>
#include <android_image.h>
#include <mmc.h>
#include <stdlib.h>
#include <memalign.h>
#include <fdtdec.h>

#define PART_MAX_COUNT  128
#define	LAB_SIZE		512
#define	HEADER_OFFSET	LAB_SIZE
#define	ENTRY_OFFSET	(2 * LAB_SIZE)
#define	VAL1_OFFSET		sizeof(u64)
#define	VAL2_OFFSET		(2 * sizeof(u64))

static u64 get_gpt_blk_cnt_and_print(struct blk_desc *dev_desc,
			  gpt_header *gpt_head, gpt_entry **gpt_pte) {
	char efi_str[PARTNAME_SZ + 1];
	u64 gpt_part_size, gpt_blk_cnt = 0;
	gpt_entry *gpt_e;
	int i;

	gpt_e = *gpt_pte;
	for (i = 0; i < gpt_head->num_partition_entries; i++) {

		raite_gpt_convert_efi_name_to_char(efi_str, gpt_e[i].partition_name,
					     PARTNAME_SZ + 1);

		printf("%s: part: %2d name - GPT: %16s ",
		      __func__, i, efi_str);
		gpt_part_size = le64_to_cpu(gpt_e[i].ending_lba) -
			le64_to_cpu(gpt_e[i].starting_lba) + 1;
		gpt_blk_cnt += gpt_part_size;
		
		if(gpt_part_size == 1) 
			break;
		
		printf("size(LBA) - GPT: %8llu ",
		      (unsigned long long)gpt_part_size);

		printf("start LBA - GPT: %8llu \n",
		      le64_to_cpu(gpt_e[i].starting_lba));
	}

	return gpt_blk_cnt + gpt_e[0].starting_lba - 1;
}

static int get_gpt_meta_data(u64 *data_size, void **data)
{
    gpt_header *pgpt_head;
	gpt_entry *entries;
	void *meta_data;
	u64 meta_data_size, gpt_entries_size;
	struct blk_desc *dev_desc = NULL;
	struct mmc *mmc = NULL;
	u64 blk_size = 0;
	u64 blk_cnt = 0;
	u64 tag = 0x55AA;
	lbaint_t lba;
    
	if (!data_size || !data) {
		printf("%s *** ERROR: Invalid Argument(s) ***\n", __func__);
		return -1;
	}
    
    mmc = do_returnmmc();
	if (!mmc)
		return CMD_RET_FAILURE;
    
    dev_desc = mmc_get_blk_desc(mmc);
	if (!dev_desc) {
		printf("%s *** ERROR: mmc_get_blk_desc err ***\n", __func__);
		return -1;
	}

	gpt_entries_size = sizeof(gpt_entry) * PART_MAX_COUNT;
	meta_data_size = LAB_SIZE + sizeof(gpt_header) + gpt_entries_size;
	meta_data = malloc(meta_data_size);
	if(!meta_data) {
		printf("%s *** ERROR: malloc memory (gpt meta data) ***\n", __func__);
		return -1;
	}
    
    memset(meta_data, 0, meta_data_size);
	pgpt_head = (gpt_header *)((char *)meta_data + HEADER_OFFSET);
	entries = (gpt_entry *)((char *)meta_data + ENTRY_OFFSET);
	ALLOC_CACHE_ALIGN_BUFFER(legacy_mbr, mbr, dev_desc->blksz);

	/* Read MBR Header from device */
	lba = 0; /* MBR is always at 0 */
	blk_cnt = 1; /* MBR (1 block) */
	if (blk_dread(dev_desc, lba, blk_cnt, (ulong *)mbr) != 1) {
		printf("*** ERROR: Can't read MBR header ***\n");
		goto ERROR_OUT;
	}

	/* Read GPT Header from device */
	lba = GPT_PRIMARY_PARTITION_TABLE_LBA;
	blk_cnt = 1; /* GPT Header (1 block) */
	if (blk_dread(dev_desc, lba, blk_cnt, pgpt_head) != 1) {
    	printf("%s *** ERROR: Can't read GPT header ***\n", __func__);
		goto ERROR_OUT;
	}

	lba = GPT_PRIMARY_PARTITION_TABLE_LBA;
	if (validate_gpt_header(pgpt_head, lba, dev_desc->lba)) {
		printf("%s *** ERROR: validate_gpt_header GPT header ***\n", __func__);
		goto ERROR_OUT;
	}

	if (dev_desc->sig_type == SIG_TYPE_NONE) {
		efi_guid_t empty = {};
		if (memcmp(&pgpt_head->disk_guid, &empty, sizeof(empty))) {
			dev_desc->sig_type = SIG_TYPE_GUID;
			memcpy(&dev_desc->guid_sig, &pgpt_head->disk_guid,
			      sizeof(empty));
		} else if (mbr->unique_mbr_signature != 0) {
			dev_desc->sig_type = SIG_TYPE_MBR;
			dev_desc->mbr_sig = mbr->unique_mbr_signature;
		}
	}

	/* Read GPT Entries from device */
	lba = le64_to_cpu(pgpt_head->partition_entry_lba);
	blk_cnt = BLOCK_CNT((le32_to_cpu(pgpt_head->num_partition_entries) *
				   	le32_to_cpu(pgpt_head->sizeof_partition_entry)),
				  	dev_desc);
	if (blk_dread(dev_desc, lba, blk_cnt, entries) != blk_cnt) {
		printf("%s *** ERROR:read entries (lba=%llu) ***\n",
				__func__, pgpt_head->partition_entry_lba);
		goto ERROR_OUT;
	}
	
	blk_size = dev_desc->blksz;
	validate_gpt_entries(pgpt_head, entries);
	
	debug("%s read entries lba %llu (blk_cnt %llu blk_size=%llu)\n",
				__func__, (unsigned long long)(ulong)lba, blk_cnt, blk_size);
	
	blk_cnt = get_gpt_blk_cnt(dev_desc, pgpt_head, &entries);
    
    /* 
	 * build info, layout of meta_data:
	 * u64 tag | u64 blk_size | u64 blk_cnt | 488 bytes | gpt header | gpt entries
	 */
	blk_cnt = get_gpt_blk_cnt(dev_desc, pgpt_head, &entries);
	/*this value makes we known the reserved memory is available*/
	memcpy(meta_data, (void *)&tag, sizeof(u64));
	memcpy(meta_data + VAL1_OFFSET, (void *)&blk_size, sizeof(u64));
	memcpy(meta_data + VAL2_OFFSET, (void *)&blk_cnt, sizeof(u64));

	*data_size = meta_data_size;
	*data = meta_data;

	return 0;

ERROR_OUT:
	free(meta_data);
	meta_data = NULL;
	return -1;
}
```



参考：

[Device Tree（四）：文件结构解析 (wowotech.net)](http://www.wowotech.net/device_model/dt-code-file-struct-parse.html)

[Linux设备树语法分析详解教程(三)u-boot设备树的传递 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/376295326)

[Linux设备树语法分析详解教程(四)kernel的解析 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/376296222)

https://www.cnblogs.com/solo666/p/16518154.html