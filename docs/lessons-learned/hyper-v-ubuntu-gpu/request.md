can you see if the these settings exist in the document:

BIOS items to look for: 

SVM Mode

IOMMU

Above 4G Decoding

Re-Size BAR Support

SR-IOV

ACS



Detailed items:

GPU-P and the GPU partition adapter

SR-IOV and how it relates to Hyper-V IovSupportReasons

ACS — why the X570 message matters and why it’s often a platform limit

Above 4G Decoding — what it does and why it’s secondary here

Resizable BAR — performance vs virtualization role

MMIO sizing — why it was deprioritized in this case

PCIEX16_1 slot placement on this board

Get-VMPartitionableGpu — how to read the output fields

IovSupportReasons — how to interpret the two messages

Events 12006 / 12030 / 0x800705AA — what they mean together



can you see if maybe a variation of the setting exists or if settings tha tdo the same effect are available or 3. alternatively: can you figure out if ther are settings that i need to change to enable my windows hyper-v setup to allow me to let my vm's (my k3 setup in a ubuntu vm in hyperv) the ability to use my graphics card in my windows server
